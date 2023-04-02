import dataclasses
import os
import re
import subprocess
import time
from copy import deepcopy
from typing import List
from logging import info


@dataclasses.dataclass
class User:
    name: str
    password: str


def main(env_prefix: str) -> bool:
    users = parse_environment(env_prefix)

    for user in users:
        create_user(user)
        assert_user_created(user)

    return True


def _create_env_with_password(user: User):
    env = deepcopy(os.environ)
    env['USER_PASS'] = user.password
    return env


def create_user(user: User) -> None:
    info(f" >> Creating user {user.name}")
    subprocess.check_call(f"echo -n $USER_PASS | saslpasswd2 {user.name} -p",
                          shell=True, env=_create_env_with_password(user))


def assert_user_created(user: User) -> None:
    try:
        subprocess.check_call(f"testsaslauthd -u {user.name} -p $USER_PASS",
                              shell=True, env=_create_env_with_password(user))
    except subprocess.CalledProcessError as proc_err:
        raise Exception('Cannot assert user is valid in SASL') from proc_err


def parse_environment(env_prefix: str) -> List[User]:
    """
    Collects username & secret pairs from the environment

    Example:
        USER_MICHAEL_NAME=Michael
        USER_MICHAEL_SECRET=bakunin123
        USER_EMMA_NAME=Emma
        USER_EMMA_SECRET=goldman123
    """

    users = []
    for name, value in os.environ.items():
        if name.startswith(env_prefix) and name.endswith('_NAME'):
            regexp = f"{env_prefix}([A-Za-z0-9_]+)_NAME"
            sep = re.match(regexp, name).group(1)
            try:
                users.append(User(name=value, password=os.environ[f"{env_prefix}{sep}_SECRET"]))
            except KeyError as key_error:
                raise Exception('Missing environment variable') from key_error

    return users
