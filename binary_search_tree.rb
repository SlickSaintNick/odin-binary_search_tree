# frozen_string_literal: true

# Node forms the structure of the BST.
class Node
  attr_accessor :data, :left, :right

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end
end

# Tree holds a Balanced BST and associated methods.
class Tree
  attr_reader :root

  def initialize(array)
    @root = build_tree(array.sort.uniq)
  end

  def build_tree(array, start_index = 0, end_index = array.length - 1)
    return nil if start_index > end_index

    mid = (start_index + end_index) / 2
    root = Node.new(array[mid])
    root.left = build_tree(array, start_index, mid - 1)
    root.right = build_tree(array, mid + 1, end_index)
    root
  end

  def insert(value)
    cursor = Node.new(@root.data, @root.left, @root.right)
    cursor = value < cursor.data ? cursor.left : cursor.right until cursor.left.nil? && cursor.right.nil?
    if value < cursor.data
      cursor.left = Node.new(value)
    else
      cursor.right = Node.new(value)
    end
  end

  def delete(root = @root, value)
    # Base case
    return root if root.nil?

    # Recursively look through the BST to find the node to be deleted.
    if root.data > value
      root.left = delete(root.left, value)
      return root
    elsif root.data < value
      root.right = delete(root.right, value)
      return root
    end

    # At this point, root is the node to be deleted. No children... delete. One child... swap and delete.
    # Two children... replace the node with its successor and delete (successor will have max one child).
    if root.left.nil?
      return replace_node(root, root.right)
    elsif root.right.nil?
      return replace_node(root, root.left)
    else
      return replace_with_successor(root)
    end
  end

  def replace_node(origin, replacement)
    origin = nil
    replacement
  end

  def replace_with_successor(root)
    successor_parent = root
    successor = root.right
    until successor.left.nil?
      successor_parent = successor
      successor = successor.left
    end
    if successor_parent != root
      successor_parent.left = successor.right
    else
      successor_parent.right = successor.right
    end

    root.data = successor.data

    successor = nil
    root
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '|   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '|   '}", true) if node.left
  end

  def find(value)
    cursor = Node.new(@root.data, @root.left, @root.right)
    until cursor.nil? || cursor.data == value
      cursor = value < cursor.data ? cursor.left : cursor.right
    end
    cursor
  end

  def level_order
    return if @root.nil?

    queue = [@root]
    values = []

    until queue.empty?
      current = queue.shift
      if block_given?
        yield current
      else
        values.push(current.data)
      end
      queue.push(current.left) unless current.left.nil?
      queue.push(current.right) unless current.right.nil?
    end
    return values unless block_given?
  end

  def inorder(node = @root, values = [])
    return if node.nil?

    inorder(node.left, values)
    if block_given?
      yield node
    else
      values.push(node.data)
    end
    inorder(node.right, values)
    values unless values.nil?
  end

  def preorder(node = @root, values = [])
    return if node.nil?

    if block_given?
      yield node
    else
      values.push(node.data)
    end
    preorder(node.left, values)
    preorder(node.right, values)
    values unless values.nil?
  end

  def postorder(node = @root, values = [])
    return if node.nil?

    postorder(node.left, values)
    postorder(node.right, values)
    if block_given?
      yield node
    else
      values.push(node.data)
    end
    values unless values.nil?
  end

  def height(root = @root)
    return nil if root.nil?

    [height(root.left), height(root.right)].compact.max.to_i + 1
  end

  def depth(node)
    cursor = Node.new(@root.data, @root.left, @root.right)
    depth = 0

    until node.nil? || cursor.data == node.data
      cursor = node.data < cursor.data ? cursor.left : cursor.right
      depth += 1
    end

    node.nil? ? nil : depth
  end

  def balanced?(node = @root)
    return if node.nil?

    return true if (height(node.left).to_i - height(node.right).to_i).abs <= 1

    return false unless balanced?(node.left) && balanced?(node.right)
  end

  def rebalance
    @root = build_tree(inorder)
  end

end

def press_enter
  puts 'Press Enter to continue...'
  gets
end

# Driver script


tree = Tree.new(Array.new(15) { rand(1..100) })
tree.pretty_print
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
puts 'Elements in order:'
puts "Level Order: #{tree.level_order}"
puts "Preorder:    #{tree.preorder}"
puts "Postorder:   #{tree.postorder}"
puts "Inorder:     #{tree.inorder}"
press_enter
puts 'Adding large numbers to unbalance the tree...'
tree.insert(120)
tree.insert(140)
tree.insert(160)
tree.insert(180)
tree.insert(200)
tree.pretty_print
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
tree.rebalance
tree.pretty_print
puts 'Rebalancing...'
puts "Is the tree balanced? #{tree.balanced?}"
press_enter
puts 'Elements in order:'
puts "Level Order: #{tree.level_order}"
puts "Preorder:    #{tree.preorder}"
puts "Postorder:   #{tree.postorder}"
puts "Inorder:     #{tree.inorder}"
