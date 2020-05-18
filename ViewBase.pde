import java.awt.geom.Rectangle2D;


class ViewBase {
    private ViewBase parentView = null;
    private ArrayList<ViewBase> childViews = new ArrayList<ViewBase>();

    PVector position = new PVector();
    float scale = 1;
    PVector size = new PVector(1,1);
    PVector origin = new PVector();
    boolean hasClip = false;
    boolean isVisible = true;


    final ViewBase getParentView() {
        return parentView;
    }


    final void setParentView(ViewBase newParentView) {
        ViewBase oldParentView = parentView;

        parentView = newParentView;

        if(oldParentView != null) {
            oldParentView.removeChildView(this);
        }
    }


    final ArrayList<ViewBase> getChildViews() {
        return childViews;
    }


    final void addChildView(ViewBase childView) {
        if(!childViews.contains(childView)) {
            childView.setParentView(this);
            childViews.add(childView);
        }
    }


    final void removeChildView(ViewBase childView) {
        childView.setParentView(null);
        childViews.remove(childView);
    }


    void makeChildsVisible() {
        for (ViewBase child : childViews) {
            child.isVisible = true;
        }
    }

    void makeChildsInvisible() {
        for (ViewBase child : childViews) {
            child.isVisible = false;
        }
    }


    final void draw() {
        Rectangle2D clipBoundary = getClipBoundary();

        if(clipBoundary == null || (clipBoundary.getWidth() > 0 && clipBoundary.getHeight() > 0)) {
            pushMatrix();

            if (clipBoundary != null) {
                clip((float)clipBoundary.getX(), (float)clipBoundary.getY(), (float)clipBoundary.getWidth(), (float)clipBoundary.getHeight());
            } else {
                noClip();
            }

            translate(position.x, position.y);
            scale(scale);
            translate(origin.x, origin.y);
            
            if (isVisible) {
                beforeDrawChildren();

                for (ViewBase childView: childViews) {
                    childView.draw();
                }

                afterDrawChildren();
            }

            popMatrix();
        }
    }

    void beforeDrawChildren() {}
    void afterDrawChildren() {}


    float composedScale() {
        float result = this.scale;

        if (this.parentView != null) {
            result *= this.parentView.composedScale();
        }

        return result;
    }

    PVector screenSizeToViewSize(PVector size) {
        PVector result = size.copy();

        if (parentView != null) {
            result = parentView.screenSizeToViewSize(result);
        }

        result.div(scale);

        return result;
    }

    PVector viewSizeToScreenSize(PVector size) {
        PVector result = size.copy();

        result.mult(scale);

        if (parentView != null) {
            result = parentView.viewSizeToScreenSize(result);
        }

        return result;
    }

    PVector screenPosToViewPos(PVector pos) {
        PVector result = pos.copy();

        if (parentView != null) {
            result = parentView.screenPosToViewPos(result);
        }

        result.sub(position);
        result.div(scale);
        result.sub(origin);

        return result;
    }
    
    PVector viewPosToScreenPos(PVector pos) {
        PVector result = pos.copy();

        result.add(origin);
        result.mult(scale);
        result.add(position);

        if (parentView != null) {
            result = parentView.viewPosToScreenPos(result);
        }

        return result;
    }

    
    Rectangle2D getClipBoundary() {
        Rectangle2D viewClip = null;
        Rectangle2D parentViewClip = null;

        if (hasClip) {
            PVector upperLeft = viewPosToScreenPos(new PVector());
            PVector screenSize = viewSizeToScreenSize(this.size);

            viewClip = new Rectangle2D.Float(upperLeft.x, upperLeft.y, screenSize.x, screenSize.y);
        }

        if (parentView != null) {
          parentViewClip = parentView.getClipBoundary();
        }

        if (viewClip != null && parentViewClip != null) {
            return parentViewClip.createIntersection(viewClip);

        } else if (viewClip != null) {
            return viewClip;

        } else if (parentViewClip != null) {
            return parentViewClip;
        }

        return null;
    }


    final boolean mousePressed(float parentViewMouseX, float parentViewMouseY) {
        float viewMouseX = (parentViewMouseX - position.x) / scale - origin.x;
        float viewMouseY = (parentViewMouseY - position.y) / scale - origin.y;

        if (hasClip == false || (viewMouseX > position.x && viewMouseY > position.y && viewMouseX < position.x + size.x && viewMouseY < position.y + size.y)) {
            if (beforeMousePressedChildren(viewMouseX, viewMouseY)) {
                return true;
            }

            boolean mousePressedHandled = false;
            for (ViewBase childView: childViews) {
                mousePressedHandled = childView.mousePressed(viewMouseX, viewMouseY) | mousePressedHandled;
            }
            if (mousePressedHandled) {
                return true;
            }

            if (afterMousePressedChildren(viewMouseX, viewMouseY)) {
                return true;
            }
        }

        return false;
    }

    boolean beforeMousePressedChildren(float viewMouseX, float viewMouseY) {
        return false;
    }


    boolean afterMousePressedChildren(float viewMouseX, float viewMouseY) {
        return false;
    }


}
