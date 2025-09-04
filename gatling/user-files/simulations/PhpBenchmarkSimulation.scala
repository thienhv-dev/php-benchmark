import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class PhpBenchmarkSimulation extends Simulation {

  val httpProtocol = http
    .baseUrl("http://php-app")
    .acceptHeader("application/json")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling/PHP-Benchmark")

  // Define scenarios for each endpoint
  val fastEndpointScenario = scenario("Fast Endpoint Load Test")
    .exec(
      http("Fast API")
        .get("/api/fast")
        .check(status.is(200))
        .check(jsonPath("$.endpoint").is("fast"))
    )

  val mediumEndpointScenario = scenario("Medium Endpoint Load Test")
    .exec(
      http("Medium API")
        .get("/api/medium")
        .check(status.is(200))
        .check(jsonPath("$.endpoint").is("medium"))
    )

  val slowEndpointScenario = scenario("Slow Endpoint Load Test")
    .exec(
      http("Slow API")
        .get("/api/slow")
        .check(status.is(200))
        .check(jsonPath("$.endpoint").is("slow"))
    )

  val healthCheckScenario = scenario("Health Check")
    .exec(
      http("Health Check")
        .get("/health")
        .check(status.is(200))
    )

  // Mixed workload scenario - simulating realistic usage
  val mixedWorkloadScenario = scenario("Mixed Workload")
    .exec(
      http("Health Check")
        .get("/health")
        .check(status.is(200))
    )
    .pause(100.milliseconds)
    .randomSwitch(
      70.0 -> exec(
        http("Fast API")
          .get("/api/fast")
          .check(status.is(200))
      ),
      20.0 -> exec(
        http("Medium API")
          .get("/api/medium")
          .check(status.is(200))
      ),
      10.0 -> exec(
        http("Slow API")
          .get("/api/slow")
          .check(status.is(200))
      )
    )

  // Setup different load patterns
  setUp(
    // Light load test
    fastEndpointScenario.inject(
      rampUsers(50) during (30.seconds),
      constantUsers(100) during (60.seconds)
    ).protocols(httpProtocol),
    
    // Medium load test
    mediumEndpointScenario.inject(
      rampUsers(20) during (30.seconds),
      constantUsers(50) during (60.seconds)
    ).protocols(httpProtocol),
    
    // Heavy load test (lower concurrency for slow endpoint)
    slowEndpointScenario.inject(
      rampUsers(10) during (30.seconds),
      constantUsers(20) during (60.seconds)
    ).protocols(httpProtocol),

    // Mixed realistic workload
    mixedWorkloadScenario.inject(
      rampUsers(100) during (60.seconds),
      constantUsers(150) during (120.seconds)
    ).protocols(httpProtocol)
  ).assertions(
    global.responseTime.max.lt(5000),
    global.responseTime.mean.lt(1000),
    global.successfulRequests.percent.gt(95)
  )
}