import setuptools
from setuptools import find_packages


def get_requirements(filename):
    with open(filename) as req_file:
        requirements = [package.strip() for package in req_file.readlines()]
    return requirements


setuptools.setup(
        name='contrail-json2sandesh',
        version='0.1.0',
        description='contrail json2sandesh package.',
        packages=find_packages(),

        # metadata
        author="OpenContrail",
        author_email="dev@lists.opencontrail.org",
        license="Apache Software License",
        url="http://www.opencontrail.org/",

        install_requires=get_requirements('requirements.txt'),
        entry_points={
          'console_scripts': [
            'contrail-json2sandesh = contrail_json2sandesh.main:main',
            ],
        },
)
