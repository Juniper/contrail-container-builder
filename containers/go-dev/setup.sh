#/bin/bash

apk update && apk upgrade && \
    apk add --no-cache bash git make protobuf

go get github.com/Juniper/contrail/cmd/contrailutil
cd /go/src/github.com/Juniper/contrail

go get github.com/gogo/protobuf/protoc-gen-gogo

mkdir public
go run cmd/contrailutil/main.go generate --schemas schemas --templates tools/templates/template_config.yaml --schema-output public/schema.json --openapi-output public/openapi.json
protoc -I /go/src/ -I /go/src/github.com/gogo/protobuf/protobuf -I ./proto --gogo_out=Mgoogle/protobuf/field_mask.proto=github.com/gogo/protobuf/types,plugins=grpc:/go/src/ proto/github.com/Juniper/contrail/pkg/models/generated.proto 
protoc -I /go/src/ -I /go/src/github.com/gogo/protobuf/protobuf -I ./proto --gogo_out=plugins=grpc:/go/src/ proto/github.com/Juniper/contrail/pkg/services/generated.proto

make install