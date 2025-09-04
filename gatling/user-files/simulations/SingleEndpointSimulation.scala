import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class SingleEndpointSimulation extends Simulation {

  val httpProtocol = http
    .baseUrl("http://php-app")
    .acceptHeader("application/json")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling/PHP-Benchmark-Single")

  // Get endpoint from system property (defaults to "fast")
  val endpoint = System.getProperty("endpoint", "fast")
  val users = Integer.getInteger("users", 50)
  val duration = Integer.getInteger("duration", 60)
  val rampDuration = Integer.getInteger("rampDuration", 30)

  val singleEndpointScenario = scenario(s"$endpoint Endpoint Test")
    .exec(
      http(s"$endpoint API")
        .get(s"/api/$endpoint")
        .check(status.is(200))
        .check(jsonPath("$.endpoint").is(endpoint))
    )

  setUp(
    singleEndpointScenario.inject(
      rampUsers(users) during (rampDuration.seconds),
      constantUsers(users) during (duration.seconds)
    )
  ).protocols(httpProtocol)
  .assertions(
    global.responseTime.max.lt(10000),
    global.successfulRequests.percent.gt(95)
  )
}