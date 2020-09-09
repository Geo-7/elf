# It Creates an elf file
module Elf
  extend self
  VERSION = "0.1.0"

  struct Elf_header
    property ei_mag : Bytes
    property ei_class : Bytes
    property ei_data : Bytes
    property ei_version : Bytes
    property ei_osabi : Bytes
    property ei_abiversion : Bytes
    property ei_pad : Bytes
    property e_type : Bytes
    property e_machine : Bytes
    property e_version : Bytes
    property e_entry : Bytes
    property e_phoff : Bytes
    property e_shoff : Bytes
    property e_flags : Bytes
    property e_ehsize : Bytes
    property e_phentsize : Bytes
    property e_phnum : Bytes
    property e_shentsize : Bytes
    property e_shnum : Bytes
    property e_shstrndx : Bytes

    def initialize
      @ei_mag = UInt8.slice(0x7f, 0x45, 0x4c, 0x46)
      @ei_class = UInt8.slice(0x02)
      @ei_data = UInt8.slice(0x01)
      @ei_version = UInt8.slice(0x01)
      @ei_osabi = UInt8.slice(0x03)
      @ei_abiversion = UInt8.slice(0)
      @ei_pad = UInt8.slice(0, 0, 0, 0, 0, 0, 0)
      @e_type = UInt8.slice(0x02, 0)
      @e_machine = UInt8.slice(0x3e, 0)
      @e_version = UInt8.slice(0x01, 0, 0, 0)
      @e_entry = UInt8.slice(0xb0, 0, 0x40, 0, 0, 0, 0, 0)
      @e_phoff = UInt8.slice(0x40, 0, 0, 0, 0, 0, 0, 0)
      @e_shoff = UInt8.slice(0, 0, 0, 0, 0, 0, 0, 0)
      @e_flags = UInt8.slice(0, 0, 0, 0)
      @e_ehsize = UInt8.slice(0x40, 0)
      @e_phentsize = UInt8.slice(0x38, 0)
      @e_phnum = UInt8.slice(2, 0)
      @e_shentsize = UInt8.slice(0x40, 0)
      @e_shnum = UInt8.slice(0, 0)
      @e_shstrndx = UInt8.slice(0, 0)
    end

    def hexdump
      {% for v in @type.instance_vars %}
        pp {{v}}.hexdump
      {% end %}
    end

    def dump
      {% for v in @type.instance_vars %}
        yield {{v}}
      {% end %}
    end
  end

  struct P_header
    property p_type : Bytes
    property p_flags : Bytes
    property p_offset : Bytes
    property p_vaddr : Bytes
    property p_paddr : Bytes
    property p_filesz : Bytes
    property p_memsz : Bytes
    property p_flags : Bytes
    property e_align : Bytes

    def initialize
      @p_type = UInt8.slice(1, 0, 0, 0)
      @p_flags = UInt8.slice(0x05, 0, 0, 0)
      @p_offset = UInt8.slice(0, 0, 0, 0, 0, 0, 0, 0)
      @p_vaddr = UInt8.slice(0, 0, 0x40, 0, 0, 0, 0, 0)
      @p_paddr = UInt8.slice(0, 0, 0x40, 0, 0, 0, 0, 0)
      @p_filesz = UInt8.slice(0, 0, 0, 0, 0, 0, 0, 0)
      @p_memsz = UInt8.slice(0, 0, 0, 0, 0, 0, 0, 0)
      @e_align = UInt8.slice(0, 0x10, 0, 0, 0, 0, 0, 0)
    end

    def hexdump
      {% for v in @type.instance_vars %}
        pp {{v}}.hexdump
      {% end %}
    end

    def dump
      {% for v in @type.instance_vars %}
        yield {{v}}
      {% end %}
    end
  end
  def make_bin(str : Array(UInt8)) 
    str.each do |s|
      pp s
    end
  end
  my_elf = Elf_header.new
  my_ptable = P_header.new
  my_ptable2 = P_header.new
  my_var = IO::Memory.new("Hello 64-bit world!\n").to_slice
  program = UInt8.slice(0xba,my_var.size,0,0,0,0x48,0x8d,0x35,0x15,0x10,0,0,0xbf,0x01,0,0,0,0xb8,1,0,0,0,0x0f,5,0x31, 0xff, 0xb8, 0x3c, 0, 0, 0, 0x0f, 5)
  file_size = program.size + 0x40 + 0x38 + 0x38
  my_ptable.p_filesz = my_ptable.p_memsz = my_ptable2.p_offset=UInt8.slice(file_size, 0, 0, 0, 0, 0, 0, 0)
  my_ptable2.p_flags = UInt8.slice(0x06, 0, 0, 0)
  my_ptable2.p_filesz = my_ptable2.p_memsz = UInt8.slice(my_var.size, 0, 0, 0, 0, 0, 0, 0)
  my_ptable2.p_vaddr = my_ptable2.p_paddr = UInt8.slice(file_size, 0x10, 0x40, 0, 0, 0, 0, 0)
  File.open("elfexec", "w") do |f|
    my_elf.dump do |v|
      f.write(v)
    end
    my_ptable.dump do |v|
      f.write(v)
    end
    my_ptable2.dump do |v|
      f.write(v)
    end
    f.write(program)
    f.write(my_var)
    f.close
  end
end
