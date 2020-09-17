#include <nlohmann/json.hpp>
#include <sdbusplus/bus.hpp>

#include <string>

namespace health
{
namespace statistics
{

using Json = nlohmann::json;

struct HealthSensorConfig
{
    std::string name;
    std::string type;
    uint16_t freq;
    uint16_t windowSize;
    double criticalHigh;
    double warningHigh;
    bool criticalLog;
    bool warningLog;
    std::string criticalTgt;
    std::string warningTgt;
    bool criticalAlarm;
    bool warningAlarm;
};

class HealthSensor
{
  public:
    //HealthSensor() = delete;
    HealthSensor(const HealthSensor&) = delete;
    HealthSensor& operator=(const HealthSensor&) = delete;
    HealthSensor(HealthSensor&&) = delete;
    HealthSensor& operator=(HealthSensor&&) = delete;
    virtual ~HealthSensor() = default;

    /** @brief Constructs EventMo
     */
    HealthSensor(const double value)
    {
        // read json file
        sensorConfigs = getSensorConfig();
        createHealthSensors();
    }

     /** @brief Parsing HostEvent config JSON file  */
    Json parseConfigFile(std::string configFile);

    /** @brief reading config for each hostEvent sensor component */
    void getConfigData(Json& data, HealthSensorConfig& cfg);

    /** @brief Create sensors for hostEvent monitoring */
    void createHealthSensors();

  private:
    std::vector<HealthSensorConfig> sensorConfigs;
    std::vector<HealthSensorConfig> getSensorConfig();
};

} // namespace sensors
} // namespace health
