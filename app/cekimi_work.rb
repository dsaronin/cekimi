# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class CekimiWork -- main work module for doing everything
#

class CekimiWork
  require_relative 'environ'
  require_relative 'cekimi_rules'
  require_relative 'verb'

  def initialize()
    
    @my_env = Environ.instance
    @my_rules = CekimiRules.new

  end

  def cekimi()
    setup_work()
    do_work()      # do the work of çekimi
    shutdown_work()

    return 1
  end

private

  def setup_work()
    Environ.log_info( "starting..." )
    Environ.put_message "\n\t#{ Environ.app_name }: otomatik fiil çekimi yazılımı; İstemde bir fiil girin.\n"
  end

  def do_work()
      # command prompt & user input
    begin
      Environ.put_prompt("\n#{ Environ.app_name } > ")  
    end    while    parse_commands( Environ.get_input_list )
 
  end

  def shutdown_work()
    Environ.log_info( "...ending" )
  end

  # parse_commands -- parses the command string and executes commands
  # args:
  #   cmdlist: array of syntatical elements
  # returns boolean: true if continue looping
  def parse_commands( cmdlist )        
    loop = true                 # user input loop while true

        # parse command
    case ( cmdlist.first || ""  ).chomp
      when  "l", "list"      then  do_list      # list rules
      when  "s", "status"    then  do_status    # print status

      when  "f", "flags"     then  do_flags     # print flags
      when  "h", "help"      then  do_help      # print help
      when  "v", "version"   then  do_version   # print version
      when  "o", "options"   then  do_options   # print options

      when  "x", "exit"      then  loop = false  # exit program
      when  "q", "quit"      then  loop = false  # exit program

      when  ""               then  loop = true   # empty line; NOP
      else        
        # treat as cekimi conjugate request
        do_conjugate( cmdlist )
    end

    return loop
                
  end

  def do_list        
    Environ.put_info ">>>>> list rules "
  end
  
  def do_status        
    Environ.put_info ">>>>> status #{ CekimiRules.cekimi_rules_count } rules"
    puts CekimiRules.cekimi_rules.keys
  end

  def do_flags        
    Environ.put_info ">>>>>  flags "
  end
  def do_help        
    Environ.put_info Environ.cekimi_help
  end
  def do_version        
    Environ.put_info Environ.app_name + " v" + Environ.cekimi_version
  end
  def do_options        
    Environ.put_info( ">>>>> options ")
  end

  def do_conjugate( list )
    begin
      verb = Verb.new( list.shift )
      puts verb.to_s
      rule = CekimiRules.get_rule( :indef_past )
      rule.parse_rule( verb )

    rescue ArgumentError
      Environ.put_error( ">>  " + $!.message )
    end  # exception handling

  end



end  # class CekimiWork
