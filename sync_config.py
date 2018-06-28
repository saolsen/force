# Sync config from heroku to k8s.
# Assumes it's being run with a shell that has heroku and hokusai all set up.
# Runs with python 2.7 because that's what hokusai uses so you can run it in
# the same shell (and be able to call hokusai)

from __future__ import print_function
import subprocess
import json
import argparse

EXCLUDES = ['PATH']

PRODUCTION_OVERRIDES = {
    'APP_URL': 'https://aa314800c3e8c11e88aca0ab05fcb23e-1760988317.us-east-1.elb.amazonaws.com',
    'COOKIE_DOMAIN': 'aa314800c3e8c11e88aca0ab05fcb23e-1760988317.us-east-1.elb.amazonaws.com',
    'FORCE_URL': 'https://aa314800c3e8c11e88aca0ab05fcb23e-1760988317.us-east-1.elb.amazonaws.com',
    'OPENREDIS_URL': 'redis://force-production.uvuuuk.0001.use1.cache.amazonaws.com:6379/0',
    'REDIS_URL': 'redis://force-production.uvuuuk.0001.use1.cache.amazonaws.com:6379/0',
}

STAGING_OVERRIDES = {
    'APP_URL': 'https://aabf554653db511e897ca12cd48ef010-1891904646.us-east-1.elb.amazonaws.com',
    'COOKIE_DOMAIN': 'aabf554653db511e897ca12cd48ef010-1891904646.us-east-1.elb.amazonaws.com',
    'FORCE_URL': 'https://aabf554653db511e897ca12cd48ef010-1891904646.us-east-1.elb.amazonaws.com',
    'OPENREDIS_URL': 'redis://force-staging.uvuuuk.0001.use1.cache.amazonaws.com:6379/0',
    'REDIS_URL': 'redis://force-staging.uvuuuk.0001.use1.cache.amazonaws.com:6379/0',
}


def sync_config(overrides, heroku_app, hokusai_env):
    heroku_env = subprocess.check_output(
        ['heroku', 'config', '--app', heroku_app]).splitlines()[1:]
    env_vars = dict([kvp.split(':', 1) for kvp in heroku_env])
    env_vars = {k: v.strip() for k, v in env_vars.items()}

    for k, v in overrides.items():
        env_vars[k] = v

    for k in EXCLUDES:
        del env_vars[k]

    env_strs = [k + '=' + v for k, v in env_vars.items()]
    to_set = env_strs
    print("Setting " + ", ".join(to_set))
    print(subprocess.check_output(
        ['hokusai', hokusai_env, 'env', 'set'] + to_set))
    print("ur done hope it aint messed up")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Sync heroku and k8s config')
    parser.add_argument('--production', action='store_true')
    args = parser.parse_args()

    if args.production:
        sync_config(PRODUCTION_OVERRIDES, 'force-production', 'production')
    else:
        sync_config(STAGING_OVERRIDES, 'force-staging', 'staging')
