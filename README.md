# mock_kbase
A fully functional packaging of the KBase data platform and mock auth to facilitate unit testing and integration testing

## Building the Dockerfile
```docker build -t mock_kbase .```

## Running the container
```docker run -p 7078:7078 --name mock_kbase mock_kbase```

## Testing SHOCK
  SHOCK is running on port 7078, which you can map to a host port of your choice.
  The SHOCK API reference is available here [https://github.com/MG-RAST/Shock/wiki/API]
