require "posix/spawn"

describe "Sanity Check" do
  it "executes successfully with default config" do
    pid, _, out, err = POSIX::Spawn.popen4("/usr/src/app/bin/codeclimate-checkstyle", "/usr/src/app/fixtures/default/config.json")
    _, status = Process::waitpid2(pid)

    expect(status.exitstatus).to eq(0)
    expect(err.read).to be_empty
  end

  it "forwards exit code" do
    pid, _, out, err = POSIX::Spawn.popen4("/usr/src/app/bin/codeclimate-checkstyle", "/usr/src/app/fixtures/not_parseable/config.json")
    _, status = Process::waitpid2(pid)

    expect(status.exitstatus).to_not eq(0)
    expect(err.read).to_not be_empty
  end
end
