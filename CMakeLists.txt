cmake_minimum_required(VERSION 2.6)
PROJECT(ptrace)

ADD_EXECUTABLE(bootstrap bootstrap.c ptrace.c)
add_custom_command(OUTPUT ptrace.c
                   COMMAND ruby ${CMAKE_CURRENT_SOURCE_DIR}/gen_ptrace.rb)
add_custom_command(OUTPUT ptrace.yaml
                   COMMAND bootstrap ">" ptrace.yaml)
add_custom_target(PTRACE_YAML ALL DEPENDS ptrace.yaml)
