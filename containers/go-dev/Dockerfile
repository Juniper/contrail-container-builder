ARG CONTRAIL_REGISTRY=localhost:5000
FROM golang:1.10.0-alpine3.7

RUN apk update && apk upgrade && \
    apk add --no-cache bash git make protobuf

RUN go get github.com/Juniper/contrail/cmd/contrailutil
WORKDIR /go/src/github.com/Juniper/contrail

RUN go get github.com/gogo/protobuf/protoc-gen-gogo

RUN mkdir public
RUN go run cmd/contrailutil/main.go generate --schemas schemas --templates tools/templates/template_config.yaml --schema-output public/schema.json --openapi-output public/openapi.json
RUN protoc -I /go/src/ -I /go/src/github.com/gogo/protobuf/protobuf -I ./proto --gogo_out=Mgoogle/protobuf/field_mask.proto=github.com/gogo/protobuf/types,plugins=grpc:/go/src/ proto/github.com/Juniper/contrail/pkg/models/generated.proto 
RUN protoc -I /go/src/ -I /go/src/github.com/gogo/protobuf/protobuf -I ./proto --gogo_out=plugins=grpc:/go/src/ proto/github.com/Juniper/contrail/pkg/services/generated.proto

RUN make install