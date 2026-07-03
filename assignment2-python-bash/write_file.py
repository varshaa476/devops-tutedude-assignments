content = "Hello, this is my DevOps assignment file.\nWritten using Python file handling.\n"

file = open("output.txt", "w")
file.write(content)
file.close()

print("Content written to output.txt successfully!")
