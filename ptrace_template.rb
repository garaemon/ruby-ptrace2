# it will be used for generate ptrace.rb
# merging with ptrace.yaml

require "ffi"
require "yaml"

class PTrace
  module LibC
    extend FFI::Library
    ffi_lib "c"
    attach_function :getpid, [], :uint
    attach_function :ptrace, [:uint, :uint, :ulong, :ulong], :long
    attach_function :strerror, [:int], :string
  end
  def self.ptrace_requests ()
    # return a hash of the constant values of ptrace requests
    YAML.load(File.open("ptrace.yaml"))
  end
  def self.getpid()
    # return the PID of the current ruby process
    LibC.getpid()
  end
  def self.resolve_request(request)
    # convert request into an integer to pass to LibC.ptrace
    # symbol, string or integer is acceptable
    if request.is_a? Symbol
      request_str = request.to_s()
      request_num = self.ptrace_requests[request_str]
      if request_num == nil
        raise "Unknown request: #{request}" #=> RuntimeError:
      end
    elsif request.is_a? String
      request_num = self.ptrace_requests[request_str]
      if request_num == nil
        raise "Unknown request: #{request}" #=> RuntimeError:
      end
    elsif request.is_a? Integer
      if not self.ptrace_requests.values.include? request 
        raise "Unknown request: #{request}" #=> RuntimeError:
      end
      request_num = request
    end
    return request_num
  end
  def self.ptrace(request, pid, addr, data)
    # here we check if the request is valid or not
    request_num = self.resolve_request(request)
    ret = LibC.ptrace(request_num, pid, addr, data)
    # if failed, report a condition
    if ret == -1
      error_str = "ptrace(#{request}): " + LibC.strerror(FFI.errno)
      raise error_str #=> RuntimeError:
    end
    return ret
  end
end

# sample
# fork
pid = spawn("./hello-loop")
#pid = 21196
PTrace.ptrace(:PT_ATTACH, pid, 0, 0)
Process.waitpid(pid)
PTrace.ptrace(:PT_WRITE_D, pid, 0x100000f2c, 0x68697070)
PTrace.ptrace(:PT_DETACH, pid, 0, 0)
puts "finished"
