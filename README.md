# inDrive Interview Preparation

## Python practice

Open [python.ipynb](./python.ipynb) in Jupyter or VS Code and run the cells in order. The notebook contains small Python exercises covering:

- Detecting duplicate transactions
- Counting events and items
- Using `collections.Counter`
- Filtering and transforming lists with comprehensions
- Sorting records by a field
- Grouping records with `defaultdict`
- Parsing JSON

## 3. Pipeline Architecture (40-50 min)

This is where your current experience can help the most.

### Example prompt

> Design a pipeline that ingests card transactions and produces analytics dashboards.

### High-level design

```text
Source Systems
    |
    v
Kafka / Kinesis
    |
    v
Raw Storage (S3)
    |
    v
ETL Processing (Spark / Glue)
    |
    v
Iceberg Tables
    |
    v
Data Warehouse (Snowflake / Redshift / BigQuery)
    |
    v
BI Layer (Power BI / Tableau)
```

### Follow-up questions

#### Why Iceberg?

Key benefits include:

- ACID transactions
- Schema evolution
- Time travel
- Partition evolution
- Table-management features beyond plain Parquet files

#### How do you handle late-arriving records?

Possible approaches:

- Upserts or `MERGE`
- Watermarks
- Incremental processing
- Use event time rather than processing time

#### How do you ensure data quality?

Discuss checks and tools such as:

- Great Expectations or Deequ
- Row-count and null checks
- Duplicate validation
- Reconciliation against the source

#### How would you process 1 billion records?

Consider:

- Partitioning
- Distributed processing with Spark
- Incremental loads
- Predicate pushdown
- Columnar formats such as Parquet or Iceberg
- Avoiding full table scans

## Questions relevant to your experience

### Iceberg

If asked about your Iceberg migration experience, prepare to discuss:

- Iceberg vs. Parquet
- Iceberg vs. Delta Lake
- `MERGE`
- Snapshot isolation
- Partition strategy

### AWS

Review the services and concepts relevant to the role:

- S3
- Lambda
- SQS
- DynamoDB
- Glue
- Athena
- IAM
- CloudWatch

#### Why use SQS between systems?

Explain how it supports decoupling, retry handling, and buffering traffic spikes.

### DynamoDB

Be ready to explain the difference between a partition key and a sort key.

## Questions to ask the interviewer

At the end of the interview, consider asking:

- How is the data platform structured today?
- Are you operating batch, streaming, or hybrid workloads?
- What is the biggest scaling challenge the team is facing?
- How is data quality monitored?
- What is the platform roadmap for the next year?