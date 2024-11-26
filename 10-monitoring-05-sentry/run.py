import sentry_sdk

sentry_sdk.init(
    dsn="https://923b81b3db4e8749f045ea1e1a20799a@o4508366526611456.ingest.us.sentry.io/4508366558068736",
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for tracing.
    traces_sample_rate=1.0,
)

def slow_function():
    import time
    time.sleep(0.1)
    return "done"

def fast_function():
    import time
    time.sleep(0.05)
    return 1 / 0

# Manually call start_profiler and stop_profiler
# to profile the code in between
sentry_sdk.profiler.start_profiler()
for i in range(0, 10):
    slow_function()
    fast_function()
#
# Calls to stop_profiler are optional - if you don't stop the profiler, it will keep profiling
# your application until the process exits or stop_profiler is called.
sentry_sdk.profiler.stop_profiler()