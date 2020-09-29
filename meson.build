project(
    'health-statistics',
    'cpp',
    version: '1.0',
    default_options: [
        'cpp_std=c++17',
    ],
)

executable(
    'health-statistics',
    [
        'HealthSensorCreate.cpp',
    ],
    dependencies: [
        dependency('phosphor-logging'),
        dependency('sdbusplus'),
        dependency('phosphor-dbus-interfaces'),
        dependency('sdeventplus'),
        dependency('threads'),
    ],
    install: true,
    install_dir: get_option('bindir')
)

install_data(sources : 'bmc_healthSensors_config.json', install_dir : '/etc/health-statistics')

conf_data = configuration_data()
conf_data.set('HEALTH_SENSOR_CONFIG_FILE', '"/etc/health-statistics/bmc_healthSensors_config.json"')
conf_data.set('HEALTH_BUS_NAME', '"xyz.openbmc_project.HealthStatistics"')
conf_data.set('HEALTH_SENSOR_PATH', '"/xyz/openbmc_project/sensors/"')

configure_file(output : 'config.h',
               configuration : conf_data)

systemd = dependency('systemd')
conf_data = configuration_data()
conf_data.set('bindir', get_option('prefix') / get_option('bindir'))
configure_file(
  input: 'health-statistics.service.in',
  output:'health-statistics.service',
  configuration: conf_data,
  install: true,
  install_dir: systemd.get_pkgconfig_variable('systemdsystemunitdir'))

configure_file(
  input: 'usage-statistics-monitor.service',
  output:'usage-statistics-monitor.service',
  configuration: conf_data,
  install: true,
  install_dir: systemd.get_pkgconfig_variable('systemdsystemunitdir'))

install_data(['usage-statistics-monitor.sh'],
             install_dir : '/usr/bin',
             install_mode: 'rwxr-xr-x'
             )