using System;
using System.ComponentModel;
using System.Net;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;

namespace janono.demo.GlobalAzure2022.FunctionApp
{
    public class IsAlive
    {
        public static readonly string ApplicationVersion = Assembly.GetExecutingAssembly().GetName().Version.ToString();

        private readonly ILogger<IsAlive> _logger;

        public IsAlive(ILogger<IsAlive> log)
        {
            _logger = log;
        }

        [FunctionName("IsAlive")]
        [OpenApiOperation(operationId: "Run", tags: new[] { "name" })]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
        public Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            var result = new IsAliveContract
            {
                isAlive = true,
                timestamp = DateTimeOffset.UtcNow,
                version = ApplicationVersion,
                regionName = Environment.GetEnvironmentVariable("REGION_NAME")
            };
            return Task.FromResult<IActionResult>(new OkObjectResult(result));
        }
    }

    [Description("Is Alive Contract")]
    public class IsAliveContract
    {
        [System.ComponentModel.DataAnnotations.Display(Description = "Version of Application")]
        public string version { get; set; }

        [System.ComponentModel.DataAnnotations.Display(Description = "TimeStamp")]
        public DateTimeOffset timestamp { get; set; }

        [System.ComponentModel.DataAnnotations.Display(Description = "Is Alive Value")]
        public bool isAlive { get; set; }

        [System.ComponentModel.DataAnnotations.Display(Description = "Region name")]
        public string regionName { get; set; }
    }
}

