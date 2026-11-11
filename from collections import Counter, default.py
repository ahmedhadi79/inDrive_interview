from collections import Counter, defaultdict, deque
from datetime import timedelta
import json

# 1. Count + top-k: top 3 cities by number of rides
def top_cities(rides, k=3):
    return Counter(r["city"] for r in rides).most_common(k)

# 2. Group + aggregate: average fare per driver
def avg_fare_per_driver(rides):
    totals = defaultdict(lambda: [0.0, 0])          # driver -> [sum, count]
    for r in rides:
        t = totals[r["driver_id"]]
        t[0] += r["fare"]
        t[1] += 1
    return {d: s / c for d, (s, c) in totals.items()}

# 3. Dedup, keep the latest version of each record
def latest_per_id(events):
    latest = {}
    for e in events:
        cur = latest.get(e["id"])
        if cur is None or e["updated_at"] > cur["updated_at"]:
            latest[e["id"]] = e
    return list(latest.values())

# 4. Parse JSON lines safely, count bad records instead of crashing
def parse_lines(lines):
    good, bad = [], 0
    for line in lines:
        try:
            rec = json.loads(line)
            if "ride_id" not in rec:
                raise ValueError("missing ride_id")
            good.append(rec)
        except (json.JSONDecodeError, ValueError):
            bad += 1                                 # in production: send to a dead-letter queue
    return good, bad

# 5. Merge overlapping intervals: total online time of a driver
def merge_intervals(intervals):
    merged = []
    for start, end in sorted(intervals):
        if merged and start <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], end)
        else:
            merged.append([start, end])
    return merged

# 6. Sessionize: a new session starts after a 30-minute gap
def count_sessions(timestamps, gap=timedelta(minutes=30)):
    ts = sorted(timestamps)
    if not ts:
        return 0
    return 1 + sum(1 for prev, cur in zip(ts, ts[1:]) if cur - prev > gap)

# 7. Sliding window: max rides in any 60-minute window
def max_in_window(timestamps, window=timedelta(hours=1)):
    q, best = deque(), 0
    for t in sorted(timestamps):
        q.append(t)
        while t - q[0] >= window:
            q.popleft()
        best = max(best, len(q))
    return best

# 8. Process a huge file in batches with a generator (constant memory)
def read_in_batches(path, size=10_000):
    batch = []
    with open(path) as f:
        for line in f:
            batch.append(line)
            if len(batch) == size:
                yield batch
                batch = []
    if batch:
        yield batch

# 9. Flatten nested JSON: {"a": {"b": 1}} -> {"a.b": 1}
def flatten(d, parent="", sep="."):
    out = {}
    for k, v in d.items():
        key = f"{parent}{sep}{k}" if parent else k
        if isinstance(v, dict):
            out.update(flatten(v, key, sep))
        else:
            out[key] = v
    return out