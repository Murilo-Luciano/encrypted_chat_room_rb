require 'socket'
#       KIDRSA

#4442
a = 400
b = 400
a1 = 400
b1 = 200

m = (a*b) - 1   # SECRET
e = (a1*m) + a
d = (b1*m) + b   # SECRET
n = ((e*d) - 1) / m

def encry(message, e, n)
    cryp = (message * e )%n
    return cryp
end

def decry(cryp, d, n)
    dryp = (cryp * d)%n
    return dryp
end

def ascii_msg(message)
    asc_msg = []
    message.split('').each do |c|
        asc_msg.push(c.ord)
    end
    return asc_msg
end

def un_ascii(ascii_chars)
    str_msg = []
    for c in ascii_chars
        str_msg.push((c.to_i).chr)
    end
    return str_msg
end

def ascii_char_encry(asc, e, n)
    cryp = []
    for c in asc
        cryp.append(encry(c ,e,n))
    end
    return cryp
end

def ascii_char_decry(cryp, d, n)
    dryp = []
    ((cryp.chomp).split(',')).each do |c|
        dryp.push(decry(c.to_i, d, n))
    end
    return dryp
end


server = TCPServer.new('127.0.0.1', 3333)
puts "Server on!"

loop do
  client = server.accept
  client_port = client.peeraddr[1]
  client_addr = client.peeraddr[2]
  
  #   SENDING AND RECEIVING PUBLIC Keys
  sv_publickey = [n, e]
  client.puts sv_publickey[0]
  client.puts sv_publickey[1]
  cl_n = client.gets
  cl_e = client.gets


  puts "Client connected: #{client_addr}"
  loop do
    # DECRYPTION -> unASCII -> MESSAGE
    msg_received = client.gets
    msg_received_unasc = un_ascii(ascii_char_decry(msg_received, d, n))
    
    if msg_received_unasc == "quit"
        client.close
        puts "Client disconnecting"
        break
    end
    
    puts "Client: #{msg_received_unasc.join ''}"
    
    # MESSAGE -> ASCII -> ENCRYPTION -> SENDING
    msg_sent = gets.chomp
    
    if msg_sent == "quit"
      puts "Disconnecting"
      client.puts "quit"
      server.close
      client.close
      break
    end

    msg_asc = ascii_msg(msg_sent)
    msg_asc_encry = ascii_char_encry(msg_asc, cl_e.to_i, cl_n.to_i)
    client.puts (msg_asc_encry.join ',')

    client.puts msg_asc_encry.join ','

  end
  
end