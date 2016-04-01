# AirRivet Example

## Usage

You can run this app in the simulator and on a device. It will display some gamescrores in a table view retrieved from a webservice on parse.com.

### Goal
We show how you can use the `AirRivet` pod to your advantage. You have to do 2 things:

1. Create a class that implements protocol `ServiceParameters`. In our example `ParseExampleService`
2. Create a model object that implements protocol `BaseModel`

Take a look at the `AirRivet` pod documentation on how to use a `RequestController` to retrieve model object with the `ParseExampleService` you just created.

## Requirements
iOS8 or higher
