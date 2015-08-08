
import Flow from require "lapis.flow"

import Followings, Notifications from require "models"

import assert_error from require "lapis.application"

class FollowingsFlow extends Flow
  expose_assigns: true

  new: (...) =>
    super ...
    assert_error @current_user, "must be logged in"
  
  follow_object: (object) =>
    f = Followings\create {
      source_user_id: @current_user.id
      :object
    }

    if f and object.get_user
      Notifications\notify_for object\get_user!,
        object,
        "follow",
        @current_user

    f

  unfollow_object: (object) =>
    following = Followings\find {
      source_user_id: @current_user.id
      object_type: Followings\object_type_for_object object
      object_id: object.id
    }

    return unless following

    if object.get_user
      Notifications\undo_notify object\get_user!,
        object,
        "follow",
        @current_user

    following\delete!

