'''
 Copyright (C) 2024  Fabian Huck

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 todoistut is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import sys
import subprocess
import os
import todoist_api_python
#print(help(todoist_api_python))

from todoist_api_python.api_async import TodoistAPIAsync
from todoist_api_python.api import TodoistAPI


api_key = ""

api = None  # TodoistAPI(api_key)  # global todoist api object


file_path = os.path.realpath(__file__)
print(file_path)

#sys.path.append('/home/fabian/.local/lib/python3.12/site-packages/')
sys.path.append('')

# have to install lib with pip install todoist_api_python



def init(db_api_key):
   global api
   api = TodoistAPI(db_api_key)
   

def collab_to_dict(c):
   return {"id": c.id, "email": c.email, "name": c.name}

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

def speak(text):
    return get_tasks()[0].content

def get_projects():
  global api
  try:
      plist = api.get_projects()
      return plist
  except Exception as error:
      print(error)
      return []
  return None

def get_comments(str_task_id):
  global api
  try:
      clist = api.get_comments(task_id = str_task_id)
      return clist
  except Exception as error:
      print(error)
      return []
  return None


def get_tasks(text):
  global api
  try:
    tasks = api.get_tasks()
    #print(tasks)
    return tasks
  except Exception as error:
    print(error)
    return error
  
def get_persons(str_pid):  # project id string; if empty, loop over all projects and get list of persons
  global api
  try:
    if not str_pid is None and len(str_pid) > 0: 
      colls = api.get_collaborators(project_id=str_pid)
      ret = []
      for c in colls:
         ret.append(collab_to_dict(c))
      return ret
    else:
       # get from all projects
       # TODO: fill with code
       return []
    #print(tasks)
    return tasks
  except Exception as error:
    print(error)
    return error
  

def comment_to_dict(c):
   return c.__dict__


def task_to_dict(t):
   due = {
        "due_date": "",
        "due_is_recurring": False,
        "due_string": "",
        "due_datetime": "",
        "due_timezone": ""
    }
   if not t.due is None:
        due["due_date"] = str(t.due.date)
        due["due_is_recurring"] = str(t.due.is_recurring)
        due["due_string"] = str(t.due.string)
        due["due_datetime"] = str(t.due.datetime)
        due["due_timezone"] = str(t.due.timezone)
    
   
   retobj = {"content": t.content, 
           "id": t.id, 
           "description": t.description, 
           "project_id": t.project_id, 
           "section_id": t.section_id, 
           "parent_id": t.parent_id, 
           "assignee_id": t.assignee_id,
           "created_at": t.created_at,
           "comment_count": t.comment_count,
           "is_completed": t.is_completed,
           "priority": t.priority,
           }
   # add duration, might not exist
   try:
      retobj["duration"] =  t.duration
      retobj["duration_unit"] =  t.duration_unit
   except Exception as error:
      print("Error assigning duration: " + str(error))
       
   # Do not use sub-dictionary for due object, but add them as due_date, due_string, etc.
   for key, value in due.items():
      retobj[key] = due[key]
   return retobj
   

def get_tasks_dict():
    raw = get_tasks("")
    l = []
    for r in raw:
       l.append(task_to_dict(r))
    return l


def get_comments_dict(str_task_id):
    raw = get_comments(str_task_id)
    l = []
    for r in raw:
       l.append(comment_to_dict(r))
    return l


def get_projects_dict():
    raw = get_projects()
    l = []
    for r in raw:
       l.append({"name": r.name, "id": r.id, "comment_count": r.comment_count, "is_favorite": r.is_favorite, "num_tasks": 0})  # num_tasks is my own property, does not exist in todoist api
    return l

def add_project(pname):
  global api
  try:
    newProject = api.add_project(name=pname)
    print(newProject)
    return get_projects_dict()
  except Exception as error:
    print(error)
    return error

# content: String, pid: "12123"  -> Number as String
def add_task(pid, content):
  global api
  try:
      task = api.add_task(content=content, project_id=pid)
      return task_to_dict(task)
  except Exception as error:
      print(error)
      return None

def add_comment(commment, str_task_id):
  try:
    new_comment = api.add_comment(
        content=commment,
        task_id=str_task_id,
        attachment=None
    )
    print(new_comment)
    return comment_to_dict(new_comment)
  except Exception as error:
    print(error)
    return None
  

def update_task(tdict):
  global api
  try:
      updated_task = api.update_task(task_id = tdict["id"], due_string = tdict["due_string"], content = tdict["content"], assignee_id = tdict["assignee_id"], description = tdict["description"])
      # TODO: soemthing goes wrong when onverting the task to a dict again, but what?
      # instead, return the input dictionary
      #return task_to_dict(updated_task)
      return tdict
  except Exception as error:
      tdict["error"] = str(error)
      return tdict
  
def close_task(tid):
  global api
  try:
      task = api.close_task(task_id=tid)
      return task_to_dict(task)
  except Exception as error:
      print(error)
      return None


def delete_project(str_pid):
  global api
  try:
      is_success = api.delete_project(project_id=str_pid)
      print("Project successfully deleted")
      return True
  except Exception as error:
      print(error)
      return False
  
def delete_task(str_tid):
  global api
  try:
      is_success = api.delete_task(task_id=str_tid)
      print("Task successfully deleted")
      return True
  except Exception as error:
      print(error)
      return False


def get_project_template():
   return {"name": None, "id": "-1", "sections": []}

def load_structure_wrapper(db_api_key):
  try:
      return load_structure(db_api_key)
  except Exception as error:
      return {"projects": [], "tasks": [], "persons": [], "errors": [str(error)]}   


def load_structure(db_api_key):
   print("Initlializing handler...")
   init(db_api_key)

   print("loading all projects, sections, tasks, persons, ...")
   prolist = get_projects_dict()
   tlist = get_tasks_dict()

   people = {}
   persons = []
   for pro in prolist:
      persons = get_persons(pro["id"])
      for pers in persons:
         if not pers["id"] in people:
            people[pers["id"]] = pers
            persons.append(pers)
    
   # Map assignee ids to names
   for t in tlist:
      if t["assignee_id"] is not None:
         t["assignee_name"] = people[t["assignee_id"]]["name"]
         if t["assignee_name"] is None:
            t["assignee_name"] = ""
      else:
         t["assignee_name"] = ""

            
         
         
   # add tasks and sections to ist
   # TODO:complete this
   # ATTENTION: people is dictionary, others are lists!!
   ret = {"projects": prolist, "tasks": tlist, "persons": persons, "errors": [""]}
   return ret
  



if __name__ == '__main__':
  #install("todoist_api_python")

  # api = TodoistAPI("e58XXXXXXXXXXXXXXXXXXXXXX")  #from developer settings of: https://app.todoist.com/app/inbox
  # all_proj = add_project("Py Back Proj")
  print("-------------- PROJECTS -----------------")

  #success = delete_project("2344337199")
  # plist = get_projects_dict()
  dicStruc = load_structure()

  task_list = get_tasks("")
  print("---- Showing open TODOIST tasks -------")
  for mytask in task_list:
    print(mytask)
    if mytask.is_completed == False:
      if not mytask.assigner_id is None:  # showing only assigned tasks!!! TODO
        #print(mytask.content)
        #print(mytask.is_completed)
        print("Task: %s; Complete: %s; Task ID: %s" % (mytask.content, mytask.is_completed, mytask.id))
  
