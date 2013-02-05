/*
 * Created by Wang, Qing. All rights reserved.
 */

# 已过时，将重写内容。现在所有合并逻辑在User-Merger里面。
Merge-Strategy = require '../contacts-merging-strategy'
_ = require 'underscore' 
require! ['../util', './Checkers', './User-Merger']



(exports ? this) <<< {merge-contacts}   