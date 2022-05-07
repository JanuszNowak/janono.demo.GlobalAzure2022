using System.IO;
using System.Net;
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
    public class GlobalAzure2022
    {
        private readonly ILogger<GlobalAzure2022> _logger;

        public GlobalAzure2022(ILogger<GlobalAzure2022> log)
        {
            _logger = log;
        }

        [FunctionName("GlobalAzure2022")]
        [OpenApiOperation(operationId: "Run", tags: new[] { "name" })]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
        public Task<ContentResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            return Task.FromResult(new ContentResult
            {
                Content = "<html><head><meta charset = 'UTF-8'></head><body>" +
                "<h1>Witamy Global Azure 2022 🚀☁⚡</h1></br>" +
                "<img src ='https://globalazure.net/images/GlobalAzure2022-762.png' alt = 'Logo' width='500'/>" +
                "</body></html>",
                ContentType = "text/html"
            });
        }
    }
}

