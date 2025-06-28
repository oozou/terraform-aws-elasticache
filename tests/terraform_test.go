package test

import (
	"context"
	"flag"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatch"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/elasticache"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/oozou/terraform-test-util"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Global variables for test reporting
var (
	generateReport bool
	reportFile     string
	htmlFile       string
)

// TestMain enables custom test runner with reporting
func TestMain(m *testing.M) {
	flag.BoolVar(&generateReport, "report", false, "Generate test report")
	flag.StringVar(&reportFile, "report-file", "test-report.json", "Test report JSON file")
	flag.StringVar(&htmlFile, "html-file", "test-report.html", "Test report HTML file")
	flag.Parse()

	exitCode := m.Run()
	os.Exit(exitCode)
}

func TestTerraformAWSElastiCacheModule(t *testing.T) {
	t.Parallel()

	// Record test start time
	startTime := time.Now()
	var testResults []testutil.TestResult

	// Pick a random AWS region to test in
	awsRegion := "ap-southeast-1"

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/terraform-test",

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"prefix":      "example",
			"environment": "example",
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		terraform.Destroy(t, terraformOptions)
	}()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Define test cases with their functions
	testCases := []struct {
		name string
		fn   func(*testing.T, *terraform.Options, string)
	}{
		{"TestElasticacheClustersCreated", testElasticacheClustersCreated},
		{"TestElasticacheServerlessCreated", testElasticacheServerlessCreated},
		{"TestAlarmsCreated", testAlarmsCreated},
		{"TestSecurityGroupsCreated", testSecurityGroupsCreated},
		{"TestAutoBackupEnabled", testAutoBackupEnabled},
	}

	// Run all test cases and collect results
	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			testStart := time.Now()

			// Capture test result
			defer func() {
				testEnd := time.Now()
				duration := testEnd.Sub(testStart)

				result := testutil.TestResult{
					Name:     tc.name,
					Duration: duration.String(),
				}

				if r := recover(); r != nil {
					result.Status = "FAIL"
					result.Error = fmt.Sprintf("Panic: %v", r)
				} else if t.Failed() {
					result.Status = "FAIL"
					result.Error = "Test assertions failed"
				} else if t.Skipped() {
					result.Status = "SKIP"
				} else {
					result.Status = "PASS"
				}

				testResults = append(testResults, result)
			}()

			// Run the actual test
			tc.fn(t, terraformOptions, awsRegion)
		})
	}

	// Generate and display test report
	endTime := time.Now()
	report := testutil.GenerateTestReport(testResults, startTime, endTime)
	report.TestSuite = "Terraform AWS ElastiCache Tests"
	report.PrintReport()

	// Save reports to files
	if err := report.SaveReportToFile("test-report.json"); err != nil {
		t.Errorf("failed to save report to file: %v", err)
	}

	if err := report.SaveReportToHTML("test-report.html"); err != nil {
		t.Errorf("failed to save report to HTML: %v", err)
	}
}

// Helper function to create AWS config
func createAWSConfig(t *testing.T, region string) aws.Config {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	require.NoError(t, err, "Failed to create AWS config")
	return cfg
}

// Test that traditional ElastiCache clusters are created successfully
func testElasticacheClustersCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	cfg := createAWSConfig(t, region)
	client := elasticache.NewFromConfig(cfg)

	// Get replication group IDs from terraform outputs
	redisReplicationGroupId := terraform.Output(t, terraformOptions, "redis_traditional_replication_group_id")
	valkeyReplicationGroupId := terraform.Output(t, terraformOptions, "valkey_traditional_replication_group_id")

	// Test Redis traditional cluster
	if redisReplicationGroupId != "" {
		input := &elasticache.DescribeReplicationGroupsInput{
			ReplicationGroupId: aws.String(redisReplicationGroupId),
		}

		result, err := client.DescribeReplicationGroups(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Redis replication group")
		require.Len(t, result.ReplicationGroups, 1, "Expected exactly one Redis replication group")

		rg := result.ReplicationGroups[0]
		assert.Equal(t, "available", *rg.Status, "Redis replication group should be available")
		assert.Equal(t, "redis", *rg.Engine, "Engine should be redis")
		assert.True(t, *rg.AtRestEncryptionEnabled, "At-rest encryption should be enabled")
		assert.True(t, *rg.TransitEncryptionEnabled, "Transit encryption should be enabled")
		assert.Equal(t, "enabled", string(rg.MultiAZ), "Multi-AZ should be enabled for Redis cluster")

	}

	// Test Valkey traditional cluster
	if valkeyReplicationGroupId != "" {
		input := &elasticache.DescribeReplicationGroupsInput{
			ReplicationGroupId: aws.String(valkeyReplicationGroupId),
		}

		result, err := client.DescribeReplicationGroups(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Valkey replication group")
		require.Len(t, result.ReplicationGroups, 1, "Expected exactly one Valkey replication group")

		rg := result.ReplicationGroups[0]
		assert.Equal(t, "available", *rg.Status, "Valkey replication group should be available")
		assert.Equal(t, "valkey", *rg.Engine, "Engine should be valkey")
		assert.True(t, *rg.AtRestEncryptionEnabled, "At-rest encryption should be enabled")
		assert.True(t, *rg.TransitEncryptionEnabled, "Transit encryption should be enabled")
		// assert.Equal(t, "enabled", string(rg.MultiAZ), "Multi-AZ should be enabled for Valkey cluster")
	}
}

// Test that serverless ElastiCache caches are created successfully
func testElasticacheServerlessCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	cfg := createAWSConfig(t, region)
	client := elasticache.NewFromConfig(cfg)

	// Get serverless cache names from terraform outputs
	redisServerlessName := terraform.Output(t, terraformOptions, "redis_serverless_cache_name")
	valkeyServerlessName := terraform.Output(t, terraformOptions, "valkey_serverless_cache_name")

	// Test Redis serverless cache
	if redisServerlessName != "" {
		input := &elasticache.DescribeServerlessCachesInput{
			ServerlessCacheName: aws.String(redisServerlessName),
		}

		result, err := client.DescribeServerlessCaches(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Redis serverless cache")
		require.Len(t, result.ServerlessCaches, 1, "Expected exactly one Redis serverless cache")

		cache := result.ServerlessCaches[0]
		assert.Equal(t, "available", *cache.Status, "Redis serverless cache should be available")
		assert.Equal(t, "redis", *cache.Engine, "Engine should be redis")
		assert.NotEmpty(t, cache.Endpoint, "Endpoint should not be empty")
	}

	// Test Valkey serverless cache
	if valkeyServerlessName != "" {
		input := &elasticache.DescribeServerlessCachesInput{
			ServerlessCacheName: aws.String(valkeyServerlessName),
		}

		result, err := client.DescribeServerlessCaches(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Valkey serverless cache")
		require.Len(t, result.ServerlessCaches, 1, "Expected exactly one Valkey serverless cache")

		cache := result.ServerlessCaches[0]
		assert.Equal(t, "available", *cache.Status, "Valkey serverless cache should be available")
		assert.Equal(t, "valkey", *cache.Engine, "Engine should be valkey")
		assert.NotEmpty(t, cache.Endpoint, "Endpoint should not be empty")
	}
}

// Test that CloudWatch alarms are created
func testAlarmsCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	cfg := createAWSConfig(t, region)
	client := cloudwatch.NewFromConfig(cfg)

	// Get cache identifiers for alarm validation
	redisReplicationGroupId := terraform.Output(t, terraformOptions, "redis_traditional_replication_group_id")
	valkeyReplicationGroupId := terraform.Output(t, terraformOptions, "valkey_traditional_replication_group_id")

	// Test alarms for Redis traditional cluster
	if redisReplicationGroupId != "" {
		input := &cloudwatch.DescribeAlarmsInput{
			AlarmNamePrefix: aws.String("example-example-redis-test-redis_high_CPU"),
		}

		result, err := client.DescribeAlarms(context.TODO(), input)
		require.NoError(t, err, "Failed to describe CloudWatch alarms for Redis")
		assert.Greater(t, len(result.MetricAlarms), 0, "Should have at least one alarm for Redis cluster")

		// Check that at least one alarm is for CPU utilization
		foundCPUAlarm := false
		for _, alarm := range result.MetricAlarms {
			if alarm.MetricName != nil && *alarm.MetricName == "CPUUtilization" {
				foundCPUAlarm = true
				assert.Equal(t, "AWS/ElastiCache", *alarm.Namespace, "Alarm should be in ElastiCache namespace")
				break
			}
		}
		assert.True(t, foundCPUAlarm, "Should have CPU utilization alarm for Redis cluster")
	}

	// Test alarms for Valkey traditional cluster
	if valkeyReplicationGroupId != "" {
		input := &cloudwatch.DescribeAlarmsInput{
			AlarmNamePrefix: aws.String("example-example-valkey-test-redis_high_CPU"),
		}

		result, err := client.DescribeAlarms(context.TODO(), input)
		require.NoError(t, err, "Failed to describe CloudWatch alarms for Valkey")
		assert.Greater(t, len(result.MetricAlarms), 0, "Should have at least one alarm for Valkey cluster")
	}
}

// Test that security groups are created with proper rules
func testSecurityGroupsCreated(t *testing.T, terraformOptions *terraform.Options, region string) {
	cfg := createAWSConfig(t, region)
	client := ec2.NewFromConfig(cfg)

	// Get security group IDs from terraform outputs
	redisSecurityGroupId := terraform.Output(t, terraformOptions, "redis_traditional_security_group_id")
	valkeySecurityGroupId := terraform.Output(t, terraformOptions, "valkey_traditional_security_group_id")
	redisServerlessSecurityGroupId := terraform.Output(t, terraformOptions, "redis_serverless_security_group_id")
	valkeyServerlessSecurityGroupId := terraform.Output(t, terraformOptions, "valkey_serverless_security_group_id")

	securityGroupIds := []string{}
	if redisSecurityGroupId != "" {
		securityGroupIds = append(securityGroupIds, redisSecurityGroupId)
	}
	if valkeySecurityGroupId != "" {
		securityGroupIds = append(securityGroupIds, valkeySecurityGroupId)
	}
	if redisServerlessSecurityGroupId != "" {
		securityGroupIds = append(securityGroupIds, redisServerlessSecurityGroupId)
	}
	if valkeyServerlessSecurityGroupId != "" {
		securityGroupIds = append(securityGroupIds, valkeyServerlessSecurityGroupId)
	}

	require.Greater(t, len(securityGroupIds), 0, "Should have at least one security group")

	for _, sgId := range securityGroupIds {
		input := &ec2.DescribeSecurityGroupsInput{
			GroupIds: []string{sgId},
		}

		result, err := client.DescribeSecurityGroups(context.TODO(), input)
		require.NoError(t, err, "Failed to describe security group %s", sgId)
		require.Len(t, result.SecurityGroups, 1, "Expected exactly one security group")

		sg := result.SecurityGroups[0]
		assert.NotEmpty(t, sg.GroupName, "Security group should have a name")
		assert.NotEmpty(t, sg.Description, "Security group should have a description")

		// Check for ingress rules on port 6379
		foundIngressRule := false
		for _, rule := range sg.IpPermissions {
			if rule.FromPort != nil && *rule.FromPort == 6379 {
				foundIngressRule = true
				break
			}
		}
		assert.True(t, foundIngressRule, "Security group should have ingress rule for port 6379")
	}
}

// Test that auto backup is enabled for traditional clusters
func testAutoBackupEnabled(t *testing.T, terraformOptions *terraform.Options, region string) {
	cfg := createAWSConfig(t, region)
	client := elasticache.NewFromConfig(cfg)

	// Get replication group IDs from terraform outputs
	redisReplicationGroupId := terraform.Output(t, terraformOptions, "redis_traditional_replication_group_id")
	valkeyReplicationGroupId := terraform.Output(t, terraformOptions, "valkey_traditional_replication_group_id")

	// Test Redis traditional cluster backup settings
	if redisReplicationGroupId != "" {
		input := &elasticache.DescribeReplicationGroupsInput{
			ReplicationGroupId: aws.String(redisReplicationGroupId),
		}

		result, err := client.DescribeReplicationGroups(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Redis replication group")
		require.Len(t, result.ReplicationGroups, 1, "Expected exactly one Redis replication group")

		rg := result.ReplicationGroups[0]
		assert.Greater(t, *rg.SnapshotRetentionLimit, int32(0), "Snapshot retention should be greater than 0")
		assert.NotEmpty(t, *rg.SnapshotWindow, "Snapshot window should be configured")
	}

	// Test Valkey traditional cluster backup settings
	if valkeyReplicationGroupId != "" {
		input := &elasticache.DescribeReplicationGroupsInput{
			ReplicationGroupId: aws.String(valkeyReplicationGroupId),
		}

		result, err := client.DescribeReplicationGroups(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Valkey replication group")
		require.Len(t, result.ReplicationGroups, 1, "Expected exactly one Valkey replication group")

		rg := result.ReplicationGroups[0]
		assert.Greater(t, *rg.SnapshotRetentionLimit, int32(0), "Snapshot retention should be greater than 0")
		assert.NotEmpty(t, *rg.SnapshotWindow, "Snapshot window should be configured")
	}

	// Test serverless cache backup settings
	redisServerlessName := terraform.Output(t, terraformOptions, "redis_serverless_cache_name")
	valkeyServerlessName := terraform.Output(t, terraformOptions, "valkey_serverless_cache_name")

	if redisServerlessName != "" {
		input := &elasticache.DescribeServerlessCachesInput{
			ServerlessCacheName: aws.String(redisServerlessName),
		}

		result, err := client.DescribeServerlessCaches(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Redis serverless cache")
		require.Len(t, result.ServerlessCaches, 1, "Expected exactly one Redis serverless cache")

		cache := result.ServerlessCaches[0]
		if cache.DailySnapshotTime != nil {
			assert.NotEmpty(t, *cache.DailySnapshotTime, "Daily snapshot time should be configured")
		}
	}

	if valkeyServerlessName != "" {
		input := &elasticache.DescribeServerlessCachesInput{
			ServerlessCacheName: aws.String(valkeyServerlessName),
		}

		result, err := client.DescribeServerlessCaches(context.TODO(), input)
		require.NoError(t, err, "Failed to describe Valkey serverless cache")
		require.Len(t, result.ServerlessCaches, 1, "Expected exactly one Valkey serverless cache")

		cache := result.ServerlessCaches[0]
		if cache.DailySnapshotTime != nil {
			assert.NotEmpty(t, *cache.DailySnapshotTime, "Daily snapshot time should be configured")
		}
	}
}
