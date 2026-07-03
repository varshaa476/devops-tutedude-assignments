students = {}

while True:
    print("\n--- Student Grades Menu ---")
    print("1. Add a new student and grade")
    print("2. Update an existing student's grade")
    print("3. Print all student grades")
    print("4. Exit")
    choice = input("Enter your choice (1-4): ")

    if choice == "1":
        name = input("Enter student name: ")
        grade = input("Enter grade: ")
        students[name] = grade
        print(f"{name} added with grade {grade}")

    elif choice == "2":
        name = input("Enter student name to update: ")
        if name in students:
            grade = input("Enter new grade: ")
            students[name] = grade
            print(f"{name}'s grade updated to {grade}")
        else:
            print("Student not found.")

    elif choice == "3":
        print("\nAll Student Grades:")
        for name, grade in students.items():
            print(f"{name}: {grade}")

    elif choice == "4":
        print("Exiting program.")
        break

    else:
        print("Invalid choice, try again.")
