# ProjectTracker [![Linters](https://github.com/duderman/project_tracker/actions/workflows/linters.yml/badge.svg)](https://github.com/duderman/project_tracker/actions/workflows/linters.yml) [![Tests](https://github.com/duderman/project_tracker/actions/workflows/tests.yml/badge.svg)](https://github.com/duderman/project_tracker/actions/workflows/tests.yml) [![CodeQL](https://github.com/duderman/project_tracker/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/duderman/project_tracker/actions/workflows/github-code-scanning/codeql)


Small MVP of project tracking web app

[https://project-tracker.herokuapp.com/](https://project-tracker.herokuapp.com/)

## Features

* Create/change name/delete projects
* Change project status
* Ability to comment on project
* Logging project status changes

## Technologies

* Ruby 3.2.2
* Rails 7
* PostgreSQL 15.2
* Stimulus
* Turbo
* CI (RuboCop, Reek, RSpec via GH Actions)
* CD using Heroku

## How to run?

To run development environment locally

1. Ensure PostgreSQL is running
    * To configure DB connection you can use env vars `DB_HOST`, `DB_PORT`, `DB_USER` and `DB_PASSWORD`
2. Ensure Redis is running and accepting connections on port `6379`
3. `bundle install`
4. `bundle exec rails db:setup`
5. `bin/dev`

To run tests run the following:

```bash
bundle exec rspec
```

## TODO

* Authentication
* Authorization
* Monitoring
* Errors reporting
* Pagination
* Comments editing/removing
* Add rack-attack
* FE validations
* Sorting
* Code coverage, code climate, dependencies tracking etc

## Questions

* What is expected workload?
* How many Projects expected to be created?
* How many comments are expected?
* Do we need authentication and authorization?
* Do we need search?
* What max response time should be?
* What statuses project can have and how transitions between them should look like?
* What content comments can have? Do we need support for files/images/formatting etc
* Apart from name and status what characteristics project should have?
* How access to projects should work?
