"""
conf.py

Description:
  Sphinx documentation configuration file.

Author: Nathan Hanford

Copyright (c) 2026 Lawrence Livermore National Security (LLNS), LLC.
See COPYRIGHT file for more details.

SPDX-License-Identifier: MIT
See LICENSE file for more details
"""

project = "Phloem"
author = "Nathan Hanford"

extensions = [
    "sphinx_rtd_theme",
    ]

html_theme = "sphinx_rtd_theme"

# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    ('mpiGraph', 'mpiGraph', 'MPI point-to-point bandwidth measurement',
     ['Adam Moody'], 1),
    ('mpiBench', 'mpiBench', 'MPI collective operations performance benchmark',
     ['Adam Moody', 'Nathan Hanford'], 1),
    ('sqmr', 'sqmr', 'Sequoia Message Rate Benchmark',
     ['Andrew Friedley', 'Nathan Hanford'], 1),
    ('com', 'com', 'Presta Point-to-Point Benchmarks',
     ['Chris Chambreau', 'Nathan Hanford'], 1),
]

# If true, show URL addresses after external links.
man_show_urls = False
