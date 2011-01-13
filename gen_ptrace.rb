$ptrace_constants = ["PT_READ_I", "PT_READ_D", "PT_READ_U",
                    "PT_WRITE_I", "PT_WRITE_D", "PT_WRITE_U",
                     "PT_GETSIGINFO", "PT_CONTINUE", "PT_STEP",
                    "PTRACE_SYSEMU", "PTRACE_SYSEMU_SINGLESTEP",
                    "PT_KILL", "PT_DETACH", "PT_ATTACH", "PT_TRACE_ME",
                    "PT_SYSCALL", "PT_GETREGS", "PT_SETREGS"]

$output = File.open("ptrace.c", "w")

def gen_ptrace_constant(constant, file)
  file.puts <<EOS
#ifdef #{constant}
printf("#{constant}: %d\\n", #{constant});
#else 
printf("#{constant}: nil\\n");
#endif  /*#{constant}*/
EOS
end

def gen_ptrace_constants(file)
  file.puts <<EOS
#include <stdio.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <sys/ptrace.h>

void print_ptrace_constants(void)
{
EOS
  for const in $ptrace_constants 
    gen_ptrace_constant(const, file)
  end
  file.puts "}\n"
end 

gen_ptrace_constants($output)
