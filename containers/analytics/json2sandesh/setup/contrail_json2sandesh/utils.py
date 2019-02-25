from ConfigParser import ConfigParser
from argparse import ArgumentParser

from constants import DEFAULT_CONFIG_FILE


def parse_config_file(config_file):
    config = ConfigParser()
    config.read(config_file)

    generator_config = dict()
    generator_config["instance_id"] = config.get("INIT_GENERATOR",
                                                 "instance_id")
    generator_config["collectors"] = config.get(
        "INIT_GENERATOR",
        "collectors").split(",")
    generator_config["level"] = str(config.get("INIT_GENERATOR", "log_level"))
    generator_config["file"] = config.get("INIT_GENERATOR", "log_file")
    generator_config["enable_syslog"] = config.get("INIT_GENERATOR",
                                                   "enable_syslog")
    generator_config["syslog_facility"] = config.get("INIT_GENERATOR",
                                                     "syslog_facility")
    generator_config["sandesh_send_rate_limit"] = config.getint(
        "INIT_GENERATOR",
        "sandesh_send_rate_limit")

    interface_config = dict()
    interface_config["host"] = config.get("INTERFACE_CONFIG", "api_host")
    interface_config["port"] = config.getint("INTERFACE_CONFIG", "api_port")
    interface_config["debug"] = config.getboolean("INTERFACE_CONFIG",
                                                  "api_debug")

    return {"generator_config": generator_config,
            "interface_config": interface_config}


def parse_args():
    parser = ArgumentParser()
    parser.add_argument("--config_file", default=DEFAULT_CONFIG_FILE)

    parser.add_argument("--instance_id")
    parser.add_argument("--collectors", nargs='*')
    parser.add_argument("--log_level")
    parser.add_argument("--log_file")
    parser.add_argument("--enable_syslog")
    parser.add_argument("--syslog_facility")
    parser.add_argument("--sandesh_send_rate_limit", type=int)

    parser.add_argument("--api_host")
    parser.add_argument("--api_port")
    parser.add_argument("--api_debug")

    args = parser.parse_args()
    config = parse_config_file(args.config_file)

    if args.instance_id:
        config["generator_config"]["instance_id"] = args.instance_id
    if args.collectors:
        config["generator_config"]["collectors"] = args.collectors
    if args.log_level:
        config["generator_config"]["level"] = args.log_level
    if args.log_file:
        config["generator_config"]["file"] = args.log_file
    if args.enable_syslog:
        config["generator_config"]["enable_syslog"] = args.enable_syslog
    if args.syslog_facility:
        config["generator_config"]["syslog_facility"] = args.syslog_facility
    if args.sandesh_send_rate_limit:
        config["generator_config"]["sandesh_send_rate_limit"] = \
                                                args.sandesh_send_rate_limit

    if args.api_host:
        config["interface_config"]["host"] = args.api_host
    if args.api_port:
        config["interface_config"]["port"] = args.api_port
    if args.api_debug:
        config["interface_config"]["debug"] = args.api_debug
    return config
