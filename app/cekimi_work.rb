# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class CekimiWork -- main work module for doing everything
#

class CekimiWork
  require_relative 'environ'
  require_relative 'cekimi_rules'
  require_relative 'verb'

  #  ------------------------------------------------------------
  TRACE_GEN  = false  # to trace verb parameter breakdown
  #  ------------------------------------------------------------
 
  #  ------------------------------------------------------------
  #  initialize  -- creates a new object
  #  ------------------------------------------------------------
  def initialize()
    
    @my_env = Environ.instance
    @my_rules = CekimiRules.new

  end

  #  ------------------------------------------------------------
  #  initialize  -- creates a new cekimi system work object
  #  ------------------------------------------------------------
  def cekimi()
    setup_work()
    do_work()      # do the work of çekimi
    shutdown_work()

    return 1
  end

private

  #  ------------------------------------------------------------
  #  setup_work  -- handles initializing cekimi system
  #  ------------------------------------------------------------
  def setup_work()
    Environ.log_info( "starting..." )
    Environ.put_message "\n\t#{ Environ.app_name }: otomatik fiil çekimi yazılımı; İstemde bir fiil girin.\n"
  end

  #  ------------------------------------------------------------
  #  do_work  -- handles primary cekimi stuff
  #  ------------------------------------------------------------
  def do_work()
      # loop for command prompt & user input
    begin
      Environ.put_prompt("\n#{ Environ.app_name } > ")  
    end    while    parse_commands( Environ.get_input_list )
 
  end

  #  ------------------------------------------------------------
  #  shutdown_work  -- handles pre-termination stuff
  #  ------------------------------------------------------------
  def shutdown_work()
    Environ.log_info( "...ending" )
  end

  #  ------------------------------------------------------------
  #  parse_commands -- parses the command string and executes commands
  #  ------------------------------------------------------------
  #  args:
  #   cmdlist: array of syntatical elements
  #  returns boolean: true if continue looping
  #  ------------------------------------------------------------
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

  #  ------------------------------------------------------------
  #  do_list  -- display rules
  #  ------------------------------------------------------------
  def do_list        
    Environ.put_info ">>>>> list rules "
  end
  
  #  ------------------------------------------------------------
  #  do_status  -- display list of all cekimi rules
  #  ------------------------------------------------------------
  def do_status        
    Environ.put_info ">>>>> status #{ CekimiRules.cekimi_rules_count } rules"
    puts CekimiRules.cekimi_rules.keys
    if TRACE_GEN
       puts :indef_past.to_s + ":  " + CekimiRules.get_rule( :indef_past ).to_s
    end
  end

  #  ------------------------------------------------------------
  #  do_flags  -- display flag states
  #  ------------------------------------------------------------
  def do_flags        
    Environ.put_info ">>>>>  flags "
  end

  #  ------------------------------------------------------------
  #  do_help  -- display help line
  #  ------------------------------------------------------------
  def do_help        
    Environ.put_info Environ.cekimi_help
  end

  #  ------------------------------------------------------------
  #  do_version  -- display cekimi version
  #  ------------------------------------------------------------
  def do_version        
    Environ.put_info Environ.app_name + " v" + Environ.cekimi_version
  end

  #  ------------------------------------------------------------
  #  do_options  -- display any options
  #  ------------------------------------------------------------
  def do_options        
    Environ.put_info( ">>>>> options ")
  end

  #  ------------------------------------------------------------
  #  do_conjugate  -- kicks off a single conjugation rule
  #  args:
  #    list -- remaining cekimi cli token list
  #  ------------------------------------------------------------
  def do_conjugate( list )
    begin
      verb = Verb.new( list.shift )  # pop next entry; assume its a verb
      puts verb.to_s  if  TRACE_GEN  # trace output if enabled

  #  ------------------------------------------------------------
      # TODO: dynamically get the rules to be conjugated
      rule = CekimiRules.get_rule( :aorist )

      table_out = rule.prep_and_parse( verb )  # kicks off recursive descent parser
      Environ.log_debug( ":aorist result: " + table_out.stub )

      # table_out holds the result
      table_out.show_table 
  #  ------------------------------------------------------------
      # TODO: dynamically get the rules to be conjugated
      rule = CekimiRules.get_rule( :neg_aorist )

      table_out = rule.prep_and_parse( verb )  # kicks off recursive descent parser
      Environ.log_debug( ":neg_aorist result: " + table_out.stub )

      # table_out holds the result
      table_out.show_table 
  #  ------------------------------------------------------------

    rescue ArgumentError
      Environ.put_and_log_error( ">>  " + $!.message )
    end  # exception handling

  end

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

end  # class CekimiWork
