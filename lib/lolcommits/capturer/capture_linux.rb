# -*- encoding : utf-8 -*-
module Lolcommits
  class CaptureLinux < Capturer
    MPV_FPS = 25

    def capture_device_string
      @capture_device.nil? ? nil : "-tv device=\"#{@capture_device}\""
    end

    def capture
      debug 'LinuxCapturer: making tmp directory'
      tmpdir = Dir.mktmpdir

      # Default delay is 1s
      delay = capture_delay != 0 ? capture_delay : 1

      # There's no way to give a capture delay in mpv, but a number of frame
      # mpv's "delay" is actually a number of frames at 25 fps
      # multiply the set value (in seconds) by 25
      frames = delay.to_i * MPV_FPS

      debug 'LinuxCapturer: calling out to mpv to capture image'
      # mpv's output is ugly and useless, let's throw it away
      _stdin, stdout, _stderr = Open3.popen3("mpv -vo=image:format=jpg:outdir=#{tmpdir} #{capture_device_string} --frames=#{frames} --fps=#{MPV_FPS} tv://")
      # looks like we still need to read the output for something to happen
      stdout.read

      debug 'LinuxCapturer: calling out to mpv to capture image'

      # get last frame from tmpdir (regardless of fps)
      all_frames = Dir.glob("#{tmpdir}/*.jpg").sort_by do |f|
        File.mtime(f)
      end

      if all_frames.empty?
        debug 'LinuxCapturer: failed to capture any image'
      else
        FileUtils.mv(all_frames.last, snapshot_location)
        debug 'LinuxCapturer: cleaning up'
      end

      FileUtils.rm_rf(tmpdir)
    end
  end
end
