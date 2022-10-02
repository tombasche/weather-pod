# Publisher

The portion of the sensor pod that sends data
Utilises protobuf + gRPC to send the message on a regular interval to the weather-tracker station

## TODO

- See what happens when I shut down the cluster while it's sending stuff
  - It would be good if the pod could batch up measurements and send them all and 'catch up' so we have no gaps in measurements
