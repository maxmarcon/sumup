# TaskService

Implementation of a task scheduling service. The web service receives a list of tasks:

```
{
	"tasks": [{
		"name": "task-1",
		"command": "touch /tmp/file1"
	}, {
		"name": "task-2",
		"command": "cat /tmp/file1",
		"requires": ["task-3"]
	}, {
		"name": "task-3",
		"command": "echo 'Hello World!' > /tmp/file1",
		"requires": ["task-1"]
	}, {
		"name": "task-4",
		"command": "rm /tmp/file1",
		"requires": ["task-2", "task-3"]
	}]
}
```

where each task comes with an optional list of requirements, that is, tasks that need to run before it.

The service returns an ordered list of tasks that honours the requirements:

```
[
    {
        "command": "touch /tmp/file1",
        "name": "task-1"
    },
    {
        "command": "echo 'Hello World!' > /tmp/file1",
        "name": "task-3"
    },
    {
        "command": "cat /tmp/file1",
        "name": "task-2"
    },
    {
        "command": "rm /tmp/file1",
        "name": "task-4"
    }
]
```

If such a list does not exist, for example because the requirements are cyclic, the service returns an appropriate error.

## How to access the service

The web service exposes a single endpoint `POST /api/schedule` that receives the task
definitions as a JSON object. In order for the service to understand the request, the header `Content-Type: application/json` must be set in the request.


## Implementation details

The web service is implemented using [Phoenix](https://hexdocs.pm/phoenix/Phoenix.html). The scheduling module (`TaskService.TaskScheduler`) implements [Kahn's algorithm](https://en.wikipedia.org/wiki/Topological_sorting#Algorithms) to compute a topological sorting in the graph induced by the task definitions. Each node in the graph corresponds to a task, and there is an edge `A -> B` if and only if task B requires task A.

### Output format

If the request contains the `Accept: application/json` header, the service returns the list of ordered tasks in JSON format.

If the request contains an `Accept: text/plain` or `Accept: */*` header, the service returns the list of commands as plain text, suitable for piping into a shell script.

**NOTE:** when accessing the service with `curl`, the `Content-Type: application/json` header must be set:

`curl -d @example.json -H 'content-type: application/json' http://localhost:4000/api/schedule`


## How to start the server

```
mix deps.get
mix phx.server
```

The endpoint will be available at: `POST http://localhost:4000/api/schedule`

## How to run the tests

The test suite includes tests for the controller (`TaskServiceWeb.TaskController`) as well unit tests for the scheduler
(`TaskService.TaskScheduler`)

To run the tests:

```
mix test
```


