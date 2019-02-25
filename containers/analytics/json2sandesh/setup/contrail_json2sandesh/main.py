from utils import parse_args

from api_server import ApiServer
from generator import Generator


def main():
    config = parse_args()
    generator = Generator(config["generator_config"])
    generator.connect()

    app = ApiServer(generator)
    app.run(config["interface_config"])


if __name__ == '__main__':
    main()
