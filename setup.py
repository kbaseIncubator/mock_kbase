#/usr/bin/env python

import os
import sys

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

classifiers = [
    'Development Status :: 3 - Alpha',
    'Environment :: Other Environment',
    'Framework :: KBase',
    'Intended Audience :: Developers',
    'License :: OSI Approved :: MIT License',
    'Operating System :: MacOS :: MacOS X',
    'Operating System :: POSIX :: Linux',
    'Programming Language :: Python',
    'Programming Language :: Python :: 2.7',
    'Topic :: Scientific/Engineering :: Bio-Informatics',
    'Topic :: Software Development :: Testing'
]

config = {
    'name': 'mock_kbase',
    'version': '0.1',
    'description': 'KBase custom micro install using Docker with mocks for testing',
    'packages': [
        'mock_kbase',
        'mock_kbase.clients',
        'mock_kbase.test'
    ],
    'setup_requires': [],
    'install_requires': [
        'requests>=1.7.0', 
        'requests_toolbelt', 
        'mysql-connector>=2.1.4'
    ],
    'dependency_links': [
        'git+ssh://git@github.com/globusonline/python-nexus-client#egg=nexus-client-0.0.3'
    ],
    'test_suite': 'nose.collector',
    'tests_require': [
        'nose'
    ],
    'author': 'KBase',
    'author_email': 'http://kbase.us/contact-us/',
    'license': 'MIT',
    'classifiers': classifiers
}

def main():
    setup(
        package_dir = {'mock_kbase': 'lib/mock_kbase'},
        **config
    )
    return 0

if __name__ == "__main__":
    sys.exit(main())
