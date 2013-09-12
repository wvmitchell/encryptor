require 'digest/md5'

class Encryptor

  def initialize
    exit unless password_confirmed
  end

  def encrypt(word, rotation, decrypt=false)
    letters = word.split('')
    results = letters.collect do |letter|
      decrypt ? decrypt_letter(letter, rotation) : encrypt_letter(letter, rotation)
    end
    results.join
  end

  def triple_encrypt(word, rotation_array, decrypt=false)
    letters = word.split('')
    rotation_hash = pad_zip letters, rotation_array
    results = letters.collect do |letter|
      decrypt ? decrypt_letter(letter, rotation_hash[letter]) : encrypt_letter(letter, rotation_hash[letter])
    end
    results.join
  end

  def encrypt_file(filename, rotation, decrypt=false)
    read_file = File.open filename, 'r'
    decrypt ? (text = encrypt read_file.read, rotation, true) : (text = encrypt read_file.read, rotation)
    decrypt ? (out_file = File.open "#{filename}.decrypted", "w") : (out_file = File.open "#{filename}.encrypted", 'w')
    out_file.write text
    out_file.close
    read_file.close
  end

  def encription_writer(decrypt=false)
    puts "This script will #{decrypt ? 'decrypt' : 'encrypt'} all your text"
    puts "What rotation would you like to use?"
    rotation = gets.chomp.to_i
    puts "Great! Just start writing. Press enter to #{decrypt ? 'decrypt' : 'encrypt'} your line, and type 'quit' to exit"
    line = ""

    until line == 'quit'
      line = gets.chomp
      next if line == 'quit'
      puts "#{decrypt ? 'DECRYPTED' : 'ENCRYPTED'} ~> " + (decrypt ? "#{encrypt line, rotation, true}" : "#{encrypt line, rotation}")
    end
  end
  
  def crack(message)
    supported_characters.count.times.collect do |attempt|
      decrypt(message, attempt)
    end
  end

  
  private

  def cipher(rotation)
    chars = (' '..'z').to_a
    rot_chars = chars.rotate(rotation)
    Hash[chars.zip(rot_chars)]
  end
  
  def encrypt_letter(letter, rotation)
    cipher_for_rotation = cipher(rotation)
    cipher_for_rotation[letter]
  end

  def decrypt_letter(letter, rotation)
    cipher_for_rotation = cipher(rotation).invert
    cipher_for_rotation[letter]
  end

  def supported_characters
    (' '..'z').to_a
  end

  def password_confirmed
    puts "Please enter your password to continue"
    3.times do |t|
      pass = gets.chomp
      if Digest::MD5.hexdigest(pass) == File.open('pass_MD5.txt', 'r').read
        return true
      else
        t == 2 ? (puts "Come back when you know your password") : (puts "No, you have #{2-t} attempts left")
      end
    end
    false
  end

  def pad_zip(big_array, small_array)
    sm_index = 0
    return_hash = {}
    big_array.each do |key|
      return_hash[key] = small_array[sm_index]
      sm_index == small_array.count-1 ? sm_index = 0 : sm_index += 1
    end
    return_hash
  end
end
















