import os
import sys
import random
import shutil

TODO_FILE = '/tmp/todo.tmp'  # Tasks stored in this temporary file
#WIDTH = 80  # Terminal width
WIDTH, _ = shutil.get_terminal_size()  # Get the actual terminal width
BACKGROUND_COLORS = [
    "\033[41m",  # Red
    "\033[42m",  # Green
    "\033[43m",  # Yellow
    "\033[44m",  # Blue
    "\033[45m",  # Magenta
    "\033[46m",  # Cyan
    "\033[47m",  # White
    "\033[49m",  # Default
]

# Function to load tasks from the TODO file
def load_tasks():
    tasks_by_date = {}
    task_idx = 0

    if not os.path.exists(TODO_FILE):
        return tasks_by_date

    with open(TODO_FILE, 'r') as file:
        for line in file:
            line = line.strip()
            if not line:
                continue

            try:
                task_color, task_description, task_date = line.split(';')
                task_color = int(task_color)
            except ValueError:
                continue  # Skip lines that don't have the correct format

            if task_date not in tasks_by_date:
                tasks_by_date[task_date] = []
            tasks_by_date[task_date].append((task_idx, task_color, task_description))
            task_idx += 1

    return tasks_by_date

# Function to save tasks to the TODO file
def save_tasks(tasks_by_date):
    with open(TODO_FILE, "w") as file:
        for date, task_list in tasks_by_date.items():
            for task in task_list:
                task_idx, color, description = task
                # Save task with a tuple: task_idx, color, description, and date
                file.write(f"{color};{description};{date}\n")
                
# Function to get background color from color index
def get_background_color(task_color):
    return BACKGROUND_COLORS[task_color % len(BACKGROUND_COLORS)]

# Function to print tasks with padding
def print_tasks(index=None):
    tasks_by_date = load_tasks()
    if not tasks_by_date:
        return

    sorted_dates = sorted(tasks_by_date.keys(), reverse=True)

    if index is not None and index < len(sorted_dates):
        date_to_show = sorted_dates[index]
    else:
        date_to_show = sorted_dates[0]

    print_header(date_to_show)
    for task_idx, task_color, task_description in tasks_by_date[date_to_show]:
        print_task(task_idx, task_color, task_description)

    if index is None:
        for date in sorted_dates[1:]:
            print_header(date)
            for task_idx, task_color, task_description in tasks_by_date[date]:
                print_task(task_idx, task_color, task_description)

# Function to print the header for a date
def print_header(date):
    # Calculate leading spaces to center the header
    leading_spaces = (WIDTH - len(date)) // 2
    padded_header = f"{' ' * leading_spaces}{date}"
    # Define color codes
    white_on_black = "\033[1;37;40m"  # White text on black background
    reset = "\033[0m"  # Reset color
    # Ensure the header fills the terminal width by padding the right side
    padded_header = padded_header.ljust(WIDTH)
#    print(f"\033[1;30;47m{padded_header}\033[0m")  # Black text on gray background, bold if possible
    # Clear the terminal screen (Linux/Unix)
    os.system('clear')
    #print()
    print(f"{white_on_black}{padded_header}{reset}")

# Function to print a task with background color and padding to terminal width
def print_task(task_idx, task_color, task_description):
    text_color = "\033[30m"  # Black text
    bg_color = get_background_color(task_color)
    # Ensure the task description fills the terminal width
    padded_description = task_description.ljust(WIDTH - len(str(task_idx)) - 5)
    # Print task index and description with background color
    print(f"{bg_color}{text_color}{task_idx:3} - {padded_description}\033[0m")

# Function to remove a task by index
def remove_task(index):
    tasks_by_date = load_tasks()
    all_tasks = [(task_idx, task_color, task_description, task_date) 
                 for task_date, task_list in tasks_by_date.items()
                 for task_idx, task_color, task_description in task_list]
    
    if 0 <= index < len(all_tasks):
        del all_tasks[index]
        print(f"Task {index} removed.")
        save_tasks(all_tasks)
    else:
        print(f"Invalid task index: {index}")

# Function to remove all tasks
def remove_all_tasks():
    if os.path.exists(TODO_FILE):
        os.remove(TODO_FILE)
        print("All tasks have been removed.")
    else:
        print("No tasks found.")

# Function to add a task with a description
def add_task(description, color=None):
    if not description:
        description = input("Enter task description: ")

    color = int(input("Color index (0-7): "))
    if not 0 <= color <= 7:
        color = random.randint(0, len(BACKGROUND_COLORS) - 1)
    
    task_date = "2024-11-01"  # Placeholder for the date (you can use dynamic dates here)
    
    # Load existing tasks
    tasks_by_date = load_tasks()
    
    # Add task to the appropriate date group
    if task_date not in tasks_by_date:
        tasks_by_date[task_date] = []

    task_idx = len(tasks_by_date[task_date])  # Use the next available task index
    tasks_by_date[task_date].append((task_idx, color, description))  # Append task to the date group

    # Save tasks back to the file
    save_tasks(tasks_by_date)
    print(f"Task added: {description}")

# Function to edit a task description by index
def edit_task(index):
    tasks_by_date = load_tasks()
    all_tasks = [(task_idx, task_color, task_description, task_date)
                 for task_date, task_list in tasks_by_date.items()
                 for task_idx, task_color, task_description in task_list]

    if 0 <= index < len(all_tasks):
        # Display current description
        _, task_color, current_description, task_date = all_tasks[index]
        print(f"Current description: {current_description}")
        
        # Get new description from user
        new_description = input("Enter new task description: ")
        
        # Update the task in tasks_by_date
        for i, (task_idx, color, description) in enumerate(tasks_by_date[task_date]):
            if task_idx == all_tasks[index][0]:  # Find by task index
                tasks_by_date[task_date][i] = (task_idx, task_color, new_description)
                break

        save_tasks(tasks_by_date)
        print(f"Task {index} description updated.")
    else:
        print(f"Invalid task index: {index}")
    
# Function to show the help message
def show_help():
    print("""
Usage:
  task.py                       Print every task grouped by date
  task.py <int>                  Print only the nth date group where nth is the int
  task.py remove <int>           Remove the task with the specified index
  task.py remove all             Remove all tasks
  task.py add <description>      Add a new task with description
  task.py color <int>            Change the color of the task at the specified index
""")

# Main program
if __name__ == "__main__":
    if len(sys.argv) == 1:
        print_tasks()  # Print all tasks if no arguments
    elif sys.argv[1] in ["-h", "--help"]:
        show_help()  # Show help
    elif sys.argv[1] == "remove":
        if len(sys.argv) == 3 and sys.argv[2] == "all":
            remove_all_tasks()  # Remove all tasks
        elif len(sys.argv) == 3:
            try:
                index = int(sys.argv[2])
                remove_task(index)  # Remove a specific task by index
            except ValueError:
                print("Please provide a valid task index.")
        else:
            print("Usage: task.py remove <int> or task.py remove all")
    elif sys.argv[1] == "edit":
        if len(sys.argv) == 3:
            try:
                index = int(sys.argv[2])
                edit_task(index)  # Edit the task by index
            except ValueError:
                print("Please provide a valid task index.")
        else:
            print("Usage: task.py edit <int>")
    elif sys.argv[1] == "add":
        description = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else None
        add_task(description)  # Add a new task
    else:
        print("Unknown command. Use -h or --help for usage.")
