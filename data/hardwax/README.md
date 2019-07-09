Data from [Hardwax](https://hardwax.com/) listings, collated in July 2019.

## hardwax-listings.csv metadata

| Header | Description | Data Type |
| --- | --- | --- |
| `artist` | name of artist | text |
| `release` | name of release | text |
| `label` | name of label | text |
| `cat_no` | label catalogue number | text |
| `review` | accompanying record review | text |
| `release_id` | ID of release | number |

## Code

`scrape-hardwax.R` contains all code used to generate this dataset. Note that website listings will change, so re-running this script will produce differing results, or it may break, in future.