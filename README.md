# statbotData

## About
This repo is part of the [Statbot Swiss Project](https://www.bfs.admin.ch/bfs/de/home/dscc/blog/2023-02-statbot.html)

The project has to parts: 
1. Generate Training and Test data for the ML Model from Statistical tables belonging to Swiss Federal office of Statistics and selected cantonal statistics offices
2. ML Model to turn Natural Language Queries into SQL queries

This repo relates to the first part 1. above:

## Content of the repo

The repo consists of the following parts:
- **input data**: in `data/const/statbot_input_data.csv`: imported datasets and spatial units as csv files
- **package `statbotData`**: the function in the directory `R` make up a package of reusable functions, that are used in the pipeline to import the datasets into postgres 
- **app**: `app.R` that gives an overview about the repo and the pipelines
- **pipelines**: in `pipelines`: they contain the dataset processing as it is preapared for the postgres import and the test data (question / SQL query pairs) for the ML model per dataset

## Pipelines

The pipelines are intended to process datasets and the upload them to a remote postgres instance, for which the credentials can be configured using the `.env` file (`sample.env` is provided as template).

### Pipeline properties

Each pipeline in `data/const/statbot_input_data.csv` has the following fields
- `data_indicator`: id of the pipeline also used as directory name for the pipeline in the repo
- `status`: `uploaded` means the dataset has been uploaded to postgres, `approved` means the dataset is ready to be uploaded to postgres
- `lang`: language of the dataset

### Pipeline files

Each pipeline has a directory in `pipelines` by the name of the `data_indicator`. The pipeline script `<data_indicator>.R` downloads the dataset and preprocesses it to produce a tibble: `ds$postgres_export`. This tibble is later uploaded into postgres. 
The queries in `queries.sql` can either run on the this tibble or on the remote postgres instance. Where they run depends on the pipeline status `ds$status`
This directory has the following files:
- `<data_indicator>.R`: script for downloading a dataset, processing it and uploading it and its metadata to postgres
- `metadata_table_columns.csv`: metadata for the postgres table fields
- `metadata_tables.csv`: metadata for the postgres_table
- `queries.sql`: Natural language questions and corresponding sql queries to answer these questions
- `queries.log`: Log of the latest run of the sql queries either locally on the ds$postgres_export` or remote on the postgres database
- `sample.csv`: sample of `ds$postgres_export` as csv file

### Functions to use in the pipeline scripts

#### Step 1: Creating the dataset class

This creates the class for the dataset with all its properties, see pipeline properties above:
```
ds <- statbotData::create_dataset("A6")
```

#### Step 2: Downloading the dataset

This function downloads the dataset: the exact tool used for downloading depends on properies of the dataset, such as 
`format` and `size`:

```
ds <- statbotData::download_data(ds)
```

#### Step 3: Preprocess the data

The result of the preprocessing is a tibble that is added to the dataset class: `ds$postgres_export`.
This tibble will then be uploaded to the remote postgres instance

```
ds$postgres_export <- ...
```

#### Step 4: Generate Sample File

Generate a sample of the dataset `sample.csv`: 

```
statbotData::dataset_sample(ds)
```

#### Step 4: Make test data

Make a file with test data for the ML `queries.sql`, that should look like this 
example below:

```
-- Wieviele Abstimmungsvorlagen gab es im Jahr 2000?
SELECT COUNT(*) as anzahl_abstimmungsvorlagen_im_jahr_2000
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE AND T.jahr=2000;

-- Wieviele Abstimmungsvorlagen gab es seit dem Jahr 1971?
SELECT COUNT(*) as anzahl_abstimmungsvorlagen
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE;
```

#### Step 5: Test run your queries locally

```
statbotData::testrun_queries((ds)
```

#### Step 6: Upload your dataset to postgres

When your dataset is in the status `approved` you can upload it to the remote
postgres instance

```
statbotData::create_postgres_table(ds)
```

#### Step 7: Generate templates for the metadata

You can create template for the metadata files:
- `metadata_table_columns.csv`: metadata for the postgres table fields
- `metadata_tables.csv`: metadata for the postgres_table

```
statbotData::generate_metadata_templates(ds)
```

This will create files `metadata_table_columns.template.csv` and 
`metadata_tables.template.csv`: complete them and then rename them: 

```
mv metadata_tables.template.csv metadata_tables.csv
mv metadata_table_columns.template.csv `metadata_table_columns.csv
```

#### Step 8: Generate templates for the metadata

Update the date in the metadata if you rerun the pipeline if needed:

```
statbotData::update_pipeline_last_run_date(ds)
```

Then upload the metadata to postgres: 


```
statbotData::update_metadata_in_postgres(ds)
```

#### The update commands are safe

In case you call one of the update commands out of order, you might get an 
error, but the command will not do any harm on the remote postgres instance. 
So don't be afraid to use them.

## Shiny App

The repo also contains an app: `àpp.R`:
It can be started from R studio and provides an overview over the status of the pipelines. 
The app takes all data from the remote postgres instance once the dataset has been uploaded
to postgres. Otherwise all data is taken from the files in the `pipelines` directory.

## R package statbotData

The Repo contains an R package `statbotData`: the package provides common functions:
- for downloading of datasets
- for mapping of spatial_units
- for uploading datasets and metdata to postgres
- for generating metadata and samples on file
- for testrunning queries
