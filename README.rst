Datadog Formula
===============

SaltStack Formula to install the Datadog Agent. See the full
`Salt Formulas installation and usage instructions <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available States
================

.. contents::
    :local:

``datadog``
-----------

Installs and runs the Datadog agent. This formula uses pillar data to store the
Datadog API key for your account (see ``pillar.example``).

Testing
=========

A proper integration test suite is still a Work in Progress, in the meantime a
Docker Compose file is provided to easily check out the formula in action.

Requirements
------------

 * Docker
 * Docker Compose

Run the formula
---------------

.. code-block::

    # cd test/
    # docker-compose up
