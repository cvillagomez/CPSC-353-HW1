# Max McKee, Carlos Villagomez, Andrew Zenoni
# 02/02/18
# Assignment 3
# v 1.0.0
# Sage program. Load file and run, instructions
# on how to encrypt/decrypt are printed

# Implements a simple ADFGVX Cipher

from sage.matrix.operation_table import OperationTable
from array import array
import numpy

# Main function implementation
def main():
  key = make_key()
  user_input = ""
  
  while (str(user_input) != 'q'):
    print("Type 'encrypt' to encrypt")
    print("Type 'decrypt' to decrypt")
    print("Type 'q' to quit")
    print("Type 'keys' to view the keys")
    print("")
    user_input = raw_input(">")
    if (user_input == 'encrypt'):
      message = raw_input("input a message to encrypt: ").upper().replace(" ", "")
      encrypted = encrypt(message, key)
      print("The encrypted message is: " + encrypted)
    elif (user_input == 'decrypt'):
      cipherText = raw_input("input a message to decrypt: ")
      valid = True
      for i in cipherText:
        if (i != 'A' and i != 'D' and i != 'F' and i != 'G' and i != 'V' and i != 'X' and i != ' '):
          print("Please input valid cipther text")
          valid = False
      if valid:
        decryptedText = decrypt(cipherText, key)
        print("The decrypted message is: " + decryptedText)
    elif (user_input == 'keys'):
      print("ADFGVX matrix")
      print(key[0])
      print "Key = ", ''.join(key[1])
      print ""
    else:
      print("please input a proper token")
    print("")
    
  
# Make key generates matrix and key for encryption
def make_key():
  chars = [chr(alpha) for alpha in range(ord('A'), ord('Z') + 1)] # Add alphabetic characters
  chars = Permutations(chars).random_element()
  text_key = chars[0:6] # grab first six characters for the text key

  chars += [chr(num) for num in range(ord('0'), ord('9') + 1)] # Add numeric characters
  chars = Permutations(chars).random_element()
  matrix_key = numpy.array([chars[:6], chars[6:12], chars[12:18], chars[18:24], chars[24:30], chars[30:]])

  return (matrix_key, text_key)
  
# Encrypts plaintext message using key into ciphertext message
def encrypt(plaintext, key):

  # Create list of [row, col, row, col,...] based on matrix key (key[0])
  plaintextGridLayout = []
  for i in plaintext:
    plaintextGridLayout.append(gatherCoordinate(key[0], i))
  # Create a matrix of rows = text_key's length 
  # and columns = (plaintext length * 2) / text_key's length + 1
  numCols = len(key[1])
  numRows = float(len(plaintext) * 2 / (len(key[1])))
  
  # Determines whether or not need to create larger array
  if(numRows - int(numRows) != 0.0):
    numRows= int(numRows + 1)
  else:
    numRows = int(numRows)

  plaintextMatrix = []
  runner = 0
  first = True

  # Generates new matrix with text_key (key[1])
  for i in range(numRows):
    row = []
    for j in range(numCols):
      if runner != len(plaintext):
        if first:
          row.append(plaintextGridLayout[runner][0])
          first = False
        else:
          row.append(plaintextGridLayout[runner][1])
          runner = runner + 1
          first = True
      else:
        row.append("X")
    plaintextMatrix.append(row)

  # Add list of values to matrix, finish filling with 5
  # Get a sorted copy of the text_key
  unsortedKey = ''.join(key[1])
  sortedTextKey = ''.join(sorted(unsortedKey))
  sortedPlainTextMatrix = numpy.copy(plaintextMatrix)

  # Swap-sort each column of the matrix until sorted with key
  for i in range(0, len(sortedTextKey)):
    swapPosition = unsortedKey.find(sortedTextKey[i])
    for j in range(0, numRows):
      sortedPlainTextMatrix[j][i] = plaintextMatrix[j][swapPosition]

  # Creates output string, replace #'s with characters
  encryptStatement = ""
  for i in range(0, numCols):
    for j in range(0, max(numRows, 6)):
      if (j >= numRows):
        encryptStatement = encryptStatement + "X"
      else:
        encryptStatement = encryptStatement + str(sortedPlainTextMatrix[j][i])
    encryptStatement = encryptStatement + " "

  ecryptedLetterStatement = encryptStatement.replace("0", "A")
  ecryptedLetterStatement = ecryptedLetterStatement.replace("1", "D")
  ecryptedLetterStatement = ecryptedLetterStatement.replace("2", "F")
  ecryptedLetterStatement = ecryptedLetterStatement.replace("3", "G")
  ecryptedLetterStatement = ecryptedLetterStatement.replace("4", "V")
  ecryptedLetterStatement = ecryptedLetterStatement.replace("5", "X")

  # Output string
  return ecryptedLetterStatement
  
  
  # Decrypts ciphertext message using key back into plaintext message
def decrypt(ciphertext, key): 
  
  # Convert characters back to numbers
  encryptedStatement = ciphertext.replace("A", "0")
  encryptedStatement = encryptedStatement.replace("D", "1")
  encryptedStatement = encryptedStatement.replace("F", "2")
  encryptedStatement = encryptedStatement.replace("G", "3")
  encryptedStatement = encryptedStatement.replace("V", "4")
  encryptedStatement = encryptedStatement.replace("X", "5")
  encryptedStatement = encryptedStatement.replace(" ", "")

  # Put values back into a new matrix, cols = key text size, rows = length of chunks
  numRows = len(key[1])
  numCols = len(ciphertext) / len(key[1])
  
  runner = 0
  ciphertextMatrix = []
  # Makes matrix the wrong way
  for i in range(numRows):
    row = []
    for j in range(numCols):
      row.append(encryptedStatement[runner])
      runner = runner + 1
    ciphertextMatrix.append(row)
  tmp = []

  # Converts matrix to right side up
  for i in range(numCols):
    row = []
    for j in range(numRows):
      row.append(ciphertextMatrix[j][i])
    tmp.append(row)
  ciphertextMatrix = numpy.copy(tmp)

  # Strings for the sorting algorithim
  unsortedKey = ''.join(key[1])
  sortedTextKey = ''.join(sorted(unsortedKey))
  # Reverse the sort with sorted key and known key
  for i in range(0, len(sortedTextKey)):
    swapPosition = sortedTextKey.find(unsortedKey[i])
    for j in range(0, numCols):
      ciphertextMatrix[j][i] = tmp[j][swapPosition]

  # Put matrix into a list
  cipherList = ""
  for i in range(numCols):
    for j in range(numRows):
      cipherList = cipherList + ciphertextMatrix[i][j]

  # Construct a string based on pairs.
  decryptedText = ""
  runner = 0
  while(runner < len(cipherList)):
    decryptedText = decryptedText + getLetterFromCoordinate(key[0], int(cipherList[runner]), int(cipherList[runner+1]))
    runner = runner + 2
  

  # Output string
  return decryptedText

# Function to get a coordinate from passed in matrix based on letter
def gatherCoordinate(matrix, letter):
  x = 0
  y = 0
  for i in matrix:
    for j in i:
      if j == letter:
        return (x,y)
      x = x + 1
    y = y + 1
    x = 0
    
# Function to get the letter based off of a passed in coordinate
def getLetterFromCoordinate(matrix, num1, num2):
  return matrix[num2][num1]

# Call the main method to run program
main()