require "posix/spawn"

describe "Sanity Check" do
  it "executes successfully with default config" do
    pid, _, out, err = POSIX::Spawn.popen4("/usr/src/app/bin/codeclimate-checkstyle")
    _, status = Process::waitpid2(pid)

    expect(status.exitstatus).to eq(0)
    expect(err.read).to be_empty
  end
end
