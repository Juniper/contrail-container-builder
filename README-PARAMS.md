# Rules of PARAMS.md

Evary container folder must contain PARAMS.md which describes the container environment parameters.

Example:

| parameter              | default                        |
| ---------------------- | ------------------------------ |
| **Parameter group**    |                                |
| DIRECT_PARAMETER_A     | $INDIRECT_PARAMETER_A          |
| DIRECT_PARAMETER_B     | $INDIRECT_PARAMETER_B          |
| DIRECT_parameter_aaa   | /foo/bar                       |
| *INDIRECT_PARAMETER_A* | FQDN host name from /etc/hosts |
| *INDIRECT_PARAMETER_B* |                                |

## Parameter groups

Parameters are grouped into logical groups, such as Config, Analytics, etc.
Each group is dedicatad to TF component (Config), other component (RabbitMQ),
functional block (Keystone authentication).
Groups are placed in alphabetical order within the table. Group names are bold.

If your container use an existing parameter which is used by any other container,
find its PARAMS.md and use the same group for the parameter.

If your add a new unique parameter look in other PARAMS.md to find an appropriate group.
If such group does not exist, create a new one.

## Direct and indirect parameters

Direct parameters are used in entrypoints in various ways related to their meaning,
but indirect parameters are used as default values for other parameters only.
Direct parameters are related to entrypoint logic whereas indirect parameters are intendent
to simplify setting of direct parameters. 

Typical example of an indirect parameter is CONTROLLER_NODES which is not directly related
to any container service but may be used to set both config and analytics nodes.

Direct parameters precede indirect ones within a group. Each subgroup is sorted
alphabetically, case sensitive. Names of indirect parameters are italic.

## Default values

Default values reffers on other parameters with $ prefix.

Besides value directly default value may be a text describing what the value is.
