# Kubernetes manifests

Three different approaches can be used to employ third-party software in Contrail setup.
Details can be found in https://github.com/Juniper/contrail-container-builder/tree/master/containers/external README

* contrail-template.yml

  Uses custom containers based on stock ones for third-party software

* contrail-template-3p-init-container.yml

  Uses init containers working along with stock ones for third-party software

* contrail-template-3p-starter-script.yml

  Uses starter scripts provided as config maps inside of this very yaml and runs stock containers for third-party software
