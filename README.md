# SCD OpenStack Cloud - themes, dashboards, and Panels

## Docker

Openstack version set using the `VERSION` environment variable in the dockerfile, e.g. `VERSION=train`

Apache log Level can be set in dockerfile, e.g. `APACHE_LOGLEVEL=warn`, apache logs to stdout so can be accessed through `docker logs` command

`upper-constraints.txt` sets the python packages versions for openstack, found here: `https://opendev.org/openstack/requirements/raw/branch/stable/${VERSION}/upper-constraints.txt`, where `${VERSION}` should be substituted for the openstack version

Theme is copied into the image during build, `COMPRESS_OFFLINE = True` **must** be set in `local_settings.py` for the theme to work

`local_settings.py`, `policy` directory and `ssl certs` and `keys` are mounted at runtime using `docker run -v`, these are **REQUIRED** for the container to start

`setup.sh` is the entrypoint for the docker image, it checks the required mounts are present, sets up the apache config and starts the service

Example `docker run`:
```
docker run \
  -v <path to local_settings.py>:/etc/horizon/openstack_dashboard/local/local_settings.py \
  -v <path to policy directory>:/etc/horizon/policy \
  -v <path to hostcert>:/etc/horizon/certs/hostcert.pem \
  -v <path to hostkey>:/etc/horizon/certs/hostkey.pem \
  -d -p 443:443 --name horizon <horizon image>
```
## Custom Theme

The SCD theme is based on the material theme included in horizon, available themes set in `local_settings.py`

Further theme customisation [documentation](https://docs.openstack.org/horizon/latest/configuration/themes.html)
