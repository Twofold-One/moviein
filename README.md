# moviein

Movie information JSON REST API

### Description of available functionality:

| Method | URL Pattern     | Handler            | Action                                 |
| :----- | :-------------- | :----------------- | :------------------------------------- |
| GET    | /v1/healthcheck | healthcheckHandler | Show application information           |
| GET    | /v1/movies      | listMovieHandler   | Show the details of all movies         |
| POST   | /v1/movies      | createMovieHandler | Create a new movie                     |
| GET    | /v1/movies/:id  | showMovieHandler   | Show the details of a specific movie   |
| PATCH  | /v1/movies/:id  | updateMovieHandler | Update the details of a specific movie |
| DELETE | /v1/movies/:id  | deleteMovieHandler | Delete a specific movie                |

### Exeptions

1. JSON items with null values will be ignored and will remain unchanged.

## Directory information

The _bin_ directory contains compiled app binaries, ready for deployment to a production server.

The _cmd/api_ directory contains the application-specific code for _moveiin_ API application.

The _internal_ directory contains ancillary packages used by API.

The _migrations_ direcotry contains SQL migration files for the database.

The _remote_ directory contains the configuration files and setup scripts for production server.

The _Makefile_ contains recipes for automating common administrative tasks.
