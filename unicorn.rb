# Set the working application directory
working_directory "/var/www/bookclub"

# Unicorn PID file location
pid "/var/www/bookclub/pids/unicorn.pid"

# Path to logs
stderr_path "/var/www/bookclub/logs/unicorn.log"
stdout_path "/var/www/bookclub/logs/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.bookclub.sock"

# Number of processes
worker_processes 2

# Time-out
timeout 30
