from setuptools import find_packages, setup

setup(
    name='contrail_json2sandesh',
    version='0.1.0',
    description='contrail json2sandesh package.',
    packages=find_packages(),

    author="OpenContrail",
    author_email="dev@lists.opencontrail.org",
    license="Apache Software License",
    url="http://www.opencontrail.org/",

    entry_points={
      'console_scripts': [
        'contrail-json2sandesh = contrail_json2sandesh.main:main',
        ],
    },
)
