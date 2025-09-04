import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class StressTestSimulation extends Simulation {

  val httpProtocol = http
    .baseUrl("http://php-app")
    .acceptHeader("application/json")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling/PHP-Benchmark-Stress")

  // Stress test scenarios
  val fastStressScenario = scenario("Fast Endpoint Stress Test")
    .exec(
      http("Fast API")
        .get("/api/fast")
        .check(status.is(200))
    )
    .pause(50.milliseconds, 200.milliseconds)

  val mediumStressScenario = scenario("Medium Endpoint Stress Test")
    .exec(
      http("Medium API")
        .get("/api/medium")
        .check(status.is(200))
    )
    .pause(200.milliseconds, 500.milliseconds)

  val slowStressScenario = scenario("Slow Endpoint Stress Test")
    .exec(
      http("Slow API")
        .get("/api/slow")
        .check(status.is(200))
    )
    .pause(1.seconds, 2.seconds)

  // Aggressive stress test setup
  setUp(
    // High load on fast endpoint
    fastStressScenario.inject(
      rampUsers(200) during (60.seconds),
      constantUsers(300) during (180.seconds),
      rampUsers(500) during (60.seconds), // Peak load
      constantUsers(500) during (120.seconds)
    ).protocols(httpProtocol),
    
    // Moderate load on medium endpoint
    mediumStressScenario.inject(
      rampUsers(50) during (60.seconds),
      constantUsers(100) during (180.seconds),
      rampUsers(150) during (60.seconds),
      constantUsers(150) during (120.seconds)
    ).protocols(httpProtocol),
    
    // Lower load on slow endpoint (to prevent server overload)
    slowStressScenario.inject(
      rampUsers(20) during (60.seconds),
      constantUsers(30) during (180.seconds),
      rampUsers(50) during (60.seconds),
      constantUsers(50) during (120.seconds)
    ).protocols(httpProtocol)
  ).assertions(
    global.responseTime.percentile3.lt(15000), // 99.9th percentile under 15s
    global.responseTime.mean.lt(3000),         // Mean under 3s
    global.successfulRequests.percent.gt(90)   // 90% success rate under stress
  )
}