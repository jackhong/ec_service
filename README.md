## Installation

Clone this repo

Run bundler

    bundle

Start with your favourite ruby web application server

## EC service API methods

### GET /experiments

Return all experiments

### POST /experiments

Start an experiment

**Parameters:**

- name (required) : Experiment name
- oedl (required) : Experiment script (OEDL) body (Base64 encoded)
- props : Properties provided to run experiment

### GET /experiments/:name

Get the information of an experiment

**Parameters:**

- name (required) : Experiment name
